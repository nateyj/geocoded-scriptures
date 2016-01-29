//
//  MapViewController.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 11/12/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit
import MapKit

private let CAMERA_ANGLE = 0.01
private let DEFAULT_LATITUDE = 40.2506
private let DEFAULT_LONGITUDE = -111.65247

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Constants
    
    // default location
    private let DEFAULT_ANNOTATION = MKPointAnnotation()
    private let DEFAULT_SUBTITLE = "BYU Campus"
    private let DEFAULT_TITLE = "Tanner Building"
    
    // default camera settings
    private let DEFAULT_COORDINATE = CLLocationCoordinate2DMake(DEFAULT_LATITUDE, DEFAULT_LONGITUDE)
    private let DEFAULT_FROM_EYE_COORDINATE = CLLocationCoordinate2DMake(DEFAULT_LATITUDE - CAMERA_ANGLE, DEFAULT_LONGITUDE)
    private let DEFAULT_VIEW_ALTITUDE = CLLocationDistance(300)
    private let DEFAULT_VIEW_HEADING = CLLocationDegrees(0)
    
    private let SUGGESTION_DIALOG_SEGUE = "ShowSuggestionDialog"
    
    
    // MARK: - Properties
    
    var book: Book!
    var chapter: Int!
    var geoPlace: GeoPlace!
    var geocodedPlaces: [GeoPlace]!
    var placename: String!
    var offset: String!
    
    private var annotations = [MKPointAnnotation]()
    private var annotationSubtitle: String!
    private var annotationTitle: String!
    private var coordinate: CLLocationCoordinate2D!
    private var fromEyeCoordinate: CLLocationCoordinate2D!
    private var selectedAnnotation: MKAnnotation!
    private var viewAltitude: CLLocationDistance!
    private var viewHeading: CLLocationDegrees!
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - View controller lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadChapterPins()
    }
    
    
    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin")
        
        if view == nil {
            let pinView = MKPinAnnotationView()
            
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.pinTintColor = UIColor.redColor()
            
            view = pinView
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    // MARK: - Actions
    
    @IBAction func captureMapConfiguration(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SUGGESTION_DIALOG_SEGUE, sender: self)
    }
    
    
    @IBAction func resetZoom(sender: UIBarButtonItem) {
        deselectAnnotation()
        mapView.showAnnotations(annotations, animated: true)
        setTitle()
    }
    
    
    // MARK: - Helpers
    
    //
    // creates annotations for all geocoded places in a chapter
    //
    private func addChapterAnnotations() {
        // if there is not a chapter selected with accompanying geocoded places, add default annotation
        if self.geocodedPlaces != nil {
            // create an annotation for each geocoded place in the chapter that will be added to the map view
            for geoPlace in self.geocodedPlaces {
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = CLLocationCoordinate2DMake(geoPlace.latitude, geoPlace.longitude)
                annotation.title = geoPlace.placename
                
                self.annotations.append(annotation)
            }
            
            self.mapView.addAnnotations(self.annotations)
        } else {
            self.addDefaultAnnotation()
        }
    }
    
    //
    // add the default location as an annotation to the map view and establish settings for the camera
    //
    private func addDefaultAnnotation() {
        self.title = DEFAULT_TITLE
        
        DEFAULT_ANNOTATION.coordinate = DEFAULT_COORDINATE
        DEFAULT_ANNOTATION.title = DEFAULT_TITLE
        DEFAULT_ANNOTATION.subtitle = DEFAULT_SUBTITLE
        
        mapView.addAnnotation(DEFAULT_ANNOTATION)
        annotations.append(DEFAULT_ANNOTATION)
        
        selectedAnnotation = DEFAULT_ANNOTATION
        
        // settings for camera
        coordinate = DEFAULT_COORDINATE
        fromEyeCoordinate = DEFAULT_FROM_EYE_COORDINATE
        viewAltitude = DEFAULT_VIEW_ALTITUDE
        viewHeading = DEFAULT_VIEW_HEADING
    }
    
    //
    // deselects selected annotation and hides callout
    //
    func deselectAnnotation() {
        if let selectedAnnot = selectedAnnotation {
            mapView.deselectAnnotation(selectedAnnot, animated: true)
        }
    }
    
    //
    // finds the annotation that correlates with the place the user selected
    //
    private func getGeoPlaceAnnotation(annotations: [MKAnnotation], geoPlace: GeoPlace) -> MKAnnotation? {
        // NEEDSWORK: handle if there are no annotations in the array
        
        for annotation in annotations {
            if annotation.coordinate.latitude == geoPlace.latitude && annotation.coordinate.longitude == geoPlace.longitude {
                return annotation
            }
        }
        
        return nil
    }
    
    //
    // determines if default location is already showing
    //
    func isDefaultLocationShowing() -> Bool {
        if coordinate != nil && coordinate.latitude == DEFAULT_COORDINATE.latitude && coordinate.longitude == DEFAULT_COORDINATE.longitude {
            return true
        } else {
            return false
        }
    }
    
    
    //
    // get's what place the user wants to see and sets the camera to that place
    //
    func loadChapterPins() {
        removeAnnotations()
        
        // gives a delay of two seconds from now
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.addChapterAnnotations()
            self.mapView.showAnnotations(self.annotations, animated: true)
            
            // get annotation for selected geo place so its callout can be shown
            if let geoplace = self.geoPlace {
                self.selectedAnnotation = self.getGeoPlaceAnnotation(self.annotations, geoPlace: geoplace)
            }
            
            self.setCameraOnNewPin()
        })
    }
    
    //
    // clear the map view of any annotations already there
    //
    func removeAnnotations() {
        //self.title = "Map"
        
        if annotations.count > 0 {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        selectedAnnotation = nil
        
        // reset settings for camera
        coordinate = nil
        fromEyeCoordinate = nil
        viewHeading = nil
        viewAltitude = nil
    }
    
    //
    // shows which pin the camera will be zoomed in on
    //
    private func setCamera() {
        let camera = MKMapCamera(
            lookingAtCenterCoordinate: coordinate,
            fromEyeCoordinate: fromEyeCoordinate,
            eyeAltitude: viewAltitude)
        
        camera.heading = viewHeading
        
        mapView.setCamera(camera, animated: true)
        
        selectAnnotation() //show pin callout
    }
    
    //
    // reposition the camera to the user's newly selected geocoded place
    //
    func setCameraOnNewPin() {
        deselectAnnotation()
        
        // if there isn't a specific geo place to go to yet, then it shows whatever the user was looking at last
        if let geoplace = geoPlace {
            self.title = geoplace.placename
            
            annotationTitle = geoplace.placename
            
            coordinate = CLLocationCoordinate2DMake(geoplace.latitude, geoplace.longitude)
            fromEyeCoordinate = CLLocationCoordinate2DMake(geoplace.viewLongitude!, geoplace.viewLatitude!)
            viewHeading = geoplace.viewHeading!
            viewAltitude = geoplace.viewAltitude!
            
            selectedAnnotation = getGeoPlaceAnnotation(annotations, geoPlace: geoplace)
        }
        
        // if there's a location to zoom in, then zoom in on it
        // the time there wouldn't be a location to zoom in on is when a chapter initially loads and all the pins in that chapter are showing
        if let _ = coordinate {
            setCamera()
        }
    }
    
    //
    // show callout of selected geo place whenever user selects a geocoded place
    //
    private func selectAnnotation() {
        if let selectedAnnot = selectedAnnotation {
            mapView.selectAnnotation(selectedAnnot, animated: true)
        }
    }
    
    //
    // set map title to show the book and chapter
    //
    func setTitle() {
        var title = "Map of \(book.backName)"
        
        if chapter != 0 {
            title = title + " \(chapter)"
        }
        
        self.title = title
    }
    
    //
    // add default location as an annotation and set the camera to it
    //
    func showDefaultLocation() {
        removeAnnotations()
        addDefaultAnnotation()
        setCamera()
    }
}

