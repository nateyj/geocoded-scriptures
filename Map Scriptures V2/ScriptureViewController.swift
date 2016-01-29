//
//  ScriptureViewController.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 11/12/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit
import MapKit

class ScriptureViewController : UIViewController, UIWebViewDelegate, SuggestionDisplayDelegate {
    
    // MARK: - Constants
    
    private let MAP_SEGUE = "Show Map"
    private let SUGGESTION_DIALOG_SEGUE = "ShowSuggestionDialog"
    private let URL_PATH_PREFIX = "http://scriptures.byu.edu/mapscrip/"
    
    
    // MARK: - Properties
    
    lazy var backgroundQueue = dispatch_queue_create("background thread", nil)
    var book: Book!
    var chapter = 0
    var geoPlace: GeoPlace!
    private var invokedBySelectedText = false
    weak var mapViewController: MapViewController?
    private var placename: String!
    private var offset: String!
    private var uniqueGeocodedPlaces = [GeoPlace]()
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var webView: CustomWebView!
    
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDetailViewController()
        
        let html = ScriptureRenderer.sharedRenderer.htmlForBookId(book.id, chapter: chapter)    // gets the chapter's HTML
        webView.loadHTMLString(html, baseURL: nil) // loads this HTML into web view
        
        webView.suggestionDelegate = self
        
        // get all of the geocoded places of the chapter and put them into a model object to pass on to map view
        let geocodedPlaces = ScriptureRenderer.sharedRenderer.collectedGeocodedPlaces
        
        // create a new array that contains only unique geo places in the chapter, because a chapter can reference
        // a place multiple times
        for geoPlace in geocodedPlaces {
            guard let _ = uniqueGeocodedPlaces.indexOf({ $0.id == geoPlace.id}) else {
                uniqueGeocodedPlaces.append(geoPlace)
                continue
            }
        }
        
        if let mapVC = mapViewController {
            // if chapter has locations, load all chapter locations with their pins
            if uniqueGeocodedPlaces.count > 0 {
                mapVC.geoPlace = nil // reset the geoPlace so the map view won't zoom in on a previously selected one if it exists in the new chapter
                mapVC.geocodedPlaces = uniqueGeocodedPlaces
                mapVC.loadChapterPins()
                
                setMapTitle(mapVC)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureDetailViewController()
    }
    
    
    // MARK: - Suggestion display delegate
    
    func displaySuggestionDialog() {
        performSegueWithIdentifier(SUGGESTION_DIALOG_SEGUE, sender: self)
    }
    
    
    // MARK: Web view delegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let path = request.URL?.absoluteString {
            // if the URL path begins with the above path, then get the geoplace ID at the end of the path
            if path.hasPrefix(URL_PATH_PREFIX) {
                // gets the index we'll start at in the path to find the geoplace ID using the length of the URL path prefix
                let index = path.startIndex.advancedBy(URL_PATH_PREFIX.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                let geoPlaceID = Int(path.substringFromIndex(index))
                geoPlace = GeoDatabase.sharedGeoDatabase.geoPlaceForId(geoPlaceID!)
                
                // if in portrait mode, then load a new map, else move camera to new pin location
                if mapViewController == nil {
                    performSegueWithIdentifier(MAP_SEGUE, sender: self)
                } else {
                    // if a place is selected, adjust map to show the requested geoplace
                    mapViewController!.geoPlace = geoPlace
                    mapViewController!.setCameraOnNewPin()
                }
                
                return false
            }
        }
        
        return true
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MAP_SEGUE {
            // if destination VC is a nav VC, get its top VC and verify it's a map VC
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let mapVC = navVC.topViewController as? MapViewController {
                    // configure map view according to requested parameters
                    setMapTitle(mapVC)
                    
                    mapVC.geocodedPlaces = uniqueGeocodedPlaces
                    mapVC.geoPlace = geoPlace
                    
                    mapVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                    mapVC.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
        
        if segue.identifier == SUGGESTION_DIALOG_SEGUE {
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let suggestionVC = navVC.topViewController as? FormTableViewController {
                    getSelectedText()
                    suggestionVC.placename = placename
                    suggestionVC.offset = offset
                    
                    // get map coordinates and configuration and pass it to suggestionVC, if in landscape mode
                    if let mapVC = mapViewController {
                        // populate form fields with map configuration
                        suggestionVC.latitude = "\(mapVC.mapView.centerCoordinate.latitude)"
                        suggestionVC.longitude = "\(mapVC.mapView.centerCoordinate.longitude)"
                        suggestionVC.altitude = "\(mapVC.mapView.camera.altitude)"
                        suggestionVC.heading = "\(mapVC.mapView.camera.heading)"
                        
                        // disable button to view map from suggestion VC
                        suggestionVC.navigationItem.rightBarButtonItems![1].enabled = false
                    } else {
                        suggestionVC.geoPlace = geoPlace
                        suggestionVC.uniqueGeocodedPlaces = uniqueGeocodedPlaces
                        suggestionVC.book = book
                        suggestionVC.chapter = chapter
                    }
                }
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancelSuggestGeocoding(segue: UIStoryboardSegue) {
        resetUserInteraction()
    }
    
    @IBAction func saveSuggestGeocoding(segue: UIStoryboardSegue) {
        resetUserInteraction()
        
        if let suggestionVC = segue.sourceViewController as? FormTableViewController {
            
            //create the URL request including the values the user entered for the geocoding in the URL parameters
            
            let URLEncodedPlacename = suggestionVC.placenameTextField.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            let placenameURLParameter = "placename=" + URLEncodedPlacename!
            let latitudeURLParameter = "latitude=\(suggestionVC.latitudeTextField.text!)"
            let longitudeURLParameter = "longitude=\(suggestionVC.longitudeTextField.text!)"
            let viewLatitudeURLParameter = "viewLatitude=\(suggestionVC.viewLatitudeTextField.text!)"
            let viewLongitudeURLParameter = "viewLongitude=\(suggestionVC.viewLongitudeTextField.text!)"
            let viewTiltURLParameter = "viewTilt=\(suggestionVC.viewTiltTextField.text!)"
            let viewRollURLParameter = "viewRoll=\(suggestionVC.viewRollTextField.text!)"
            let viewAltitudeURLParameter = "viewAltitude=\(suggestionVC.viewAltitudeTextField.text!)"
            let viewHeadingURLParameter = "viewHeading=\(suggestionVC.viewHeadingTextField.text!)"
            let offsetURLParameter = "offset=\(suggestionVC.offset)"
            let bookIdURLParameter = "bookID=\(book.id)"
            let chapterURLParameter = "chapter=\(chapter)"

            let URLRequestString = "http://scriptures.byu.edu/mapscrip/suggestpm.php?" + placenameURLParameter + "&" + latitudeURLParameter + "&" + longitudeURLParameter + "&" + viewLatitudeURLParameter + "&" + viewLongitudeURLParameter + "&" + viewTiltURLParameter + "&" + viewRollURLParameter + "&" + viewAltitudeURLParameter + "&" + viewHeadingURLParameter  + "&" + offsetURLParameter  + "&" + bookIdURLParameter  + "&" + chapterURLParameter

            let URLRequest = NSURL(string: URLRequestString)
            
            dispatch_async(backgroundQueue) {
                
                let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
                
                sessionConfig.allowsCellularAccess = true
                sessionConfig.timeoutIntervalForRequest = 15.0
                sessionConfig.timeoutIntervalForResource = 15.0
                sessionConfig.HTTPMaximumConnectionsPerHost = 2
                
                let session = NSURLSession(configuration: sessionConfig)
                let request = NSURLRequest(URL: URLRequest!)
                //let request = NSURLRequest(URL: NSURL(string: "http://scriptures.byu.edu/mapscrip/suggestpm.php?placename=Salt+Lake+City&latitude=32.4123&longitude=-111.778892")!)
                
                let task = session.dataTaskWithRequest(request) {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) in
                    var succeeded = false
                    
                    if error == nil {
                        if let resultRecord = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) {
                            if let resultDict = resultRecord as? NSDictionary {
                                if let resultCode = resultDict["result"] as? Int {
                                    if resultCode == 0 {
                                        succeeded = true
                                        
                                        self.displayAlert("Success", message: "The suggestion has been saved.")
                                    }
//                                    else {
//                                        print("Request failed, reason: \(resultDict["message"])")
//                                    }
                                }
                            }
                        }
                    }
                    
                    if !succeeded {
                        self.displayAlert("Error", message: "Sorry: unable to send suggestion to server. Please check your network connection and try again.")
                    }
                }
                
                task.resume()
            }
        }
    }
    
    
    // MARK: - Helpers
    
    //
    // determines if there's a map view controller in the split view or not (landscape or portrait mode)
    //
    private func configureDetailViewController() {
        if let splitVC = splitViewController {
            mapViewController = (splitVC.viewControllers.last as! UINavigationController).topViewController as? MapViewController
        } else {
            mapViewController = nil
        }
    }
    
    //
    // displays an alert to inform user of an error or success
    //
    private func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func getSelectedText() {
        if let selectedPlacename = webView.stringByEvaluatingJavaScriptFromString("document.getSelection().toString()") {
            placename = selectedPlacename
        }
        
        if let selectionOffset = webView.stringByEvaluatingJavaScriptFromString("getSelectionOffset()") {
            offset = selectionOffset
        }
    }
    
    //
    // deselects the user's highlighted text by disabling user interactinon, then reenable user interaction again
    //
    private func resetUserInteraction() {
        webView.userInteractionEnabled = false
        webView.userInteractionEnabled = true
    }
    
    //
    // set title of map to include book and chapter
    //
    private func setMapTitle(mapVC: MapViewController) {
        mapVC.book = book
        mapVC.chapter = chapter
        mapVC.setTitle()
    }
}
