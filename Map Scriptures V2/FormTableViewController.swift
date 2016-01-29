//
//  FormTableViewController.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 12/8/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit

class FormTableViewController : UITableViewController, UITextFieldDelegate {
    
    // MARK: - Constants
    
    private let MAP_SEGUE = "Show Map"
    
    
    // MARK: - Properties
    
    var book: Book!
    var chapter: Int!
    var geoPlace: GeoPlace!
    private var isValidForm = true
    var offset: String!
    var placename: String!
    var latitude = ""
    var longitude = ""
    var altitude = "0"
    var heading = "0"
    var uniqueGeocodedPlaces: [GeoPlace]!
    
    
    // MARK: - Outlets
    
    // text fields
    @IBOutlet weak var placenameTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var viewLatitudeTextField: UITextField!
    @IBOutlet weak var viewLongitudeTextField: UITextField!
    @IBOutlet weak var viewTiltTextField: UITextField!
    @IBOutlet weak var viewRollTextField: UITextField!
    @IBOutlet weak var viewAltitudeTextField: UITextField!
    @IBOutlet weak var viewHeadingTextField: UITextField!
    
    // error labels
    @IBOutlet weak var longitudeErrorMessage: UILabel!
    
    // constraints
    @IBOutlet weak var longitudeTopConstraint: NSLayoutConstraint!
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NEEDSWORK: show form without error labels
        
        if isValidForm {
            longitudeTopConstraint.constant = 8
        }
        
//        tableView.estimatedRowHeight = 44
//        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        populateSuggestionTextFields()
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //NEEDSWORK: change cell height if the error message is there or not
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        
//        if cell?.textLabel?.text == "Longitude" {
//            print("Success!")
//        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if isValidForm {
                return 44
            } else {
                return 70
            }
        }
        
        return 70
    }
    
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() //hides the keyboard when the user hits return
        
        // if there's another table cell, change the focus to that after a user finishes typing in the current cell
        if let nextField = view.viewWithTag(textField.tag + 1) {
            nextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.selectAll(nil)    //selects all of the text in the text field when beginning to edit
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MAP_SEGUE {
            // if destination VC is a nav VC, get its top VC and verify it's a map VC
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let mapVC = navVC.topViewController as? MapViewController {
                    mapVC.deselectAnnotation()
                    setMapTitle(mapVC)
                    
                    // configure map view according to requested parameters
                    mapVC.geocodedPlaces = uniqueGeocodedPlaces
                }
            }
        }
    }
    
    @IBAction func cancelCaptureMapConfiguration(segue: UIStoryboardSegue) {
        // ignore
    }
    
    @IBAction func captureMapConfiguration(segue: UIStoryboardSegue) {
        
        // populate form with map configuration
        if let mapVC = segue.sourceViewController as? MapViewController {
            latitude = "\(mapVC.mapView.centerCoordinate.latitude)"
            longitude = "\(mapVC.mapView.centerCoordinate.longitude)"
            altitude = "\(mapVC.mapView.camera.altitude)"
            heading = "\(mapVC.mapView.camera.heading)"
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func save(sender: UIBarButtonItem) {
        
        
        if validateForm() {
            performSegueWithIdentifier("unwindToScriptureViewController", sender: self)
        } else {
            // reload table data so the row heights can adjust with any error labels
            tableView.reloadData()
        }
    }
    
    @IBAction func viewMap(sender: UIBarButtonItem) {
        performSegueWithIdentifier(MAP_SEGUE, sender: self)
    }
    
    
    // MARK: - Helpers
    
    //
    // populates the form fields with the coordinates and configuration of the map
    //
    private func populateSuggestionTextFields() {
        placenameTextField.text = placename
        latitudeTextField.text = latitude
        longitudeTextField.text = longitude
        viewAltitudeTextField.text = altitude
        viewHeadingTextField.text = heading
    }
    
    //
    // set title of map to include book and chapter
    //
    private func setMapTitle(mapVC: MapViewController) {
        mapVC.book = book
        mapVC.chapter = chapter
        mapVC.setTitle()
    }
    
    //
    // validates form checking for missing required fields and informs user of missing required fields
    //
    private func validateForm() -> Bool {
        var isFormValid = true
        
        // placename
        
        if placenameTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height, make this a method
            
            isFormValid = false
        }
        
        // latitude
        
        if latitudeTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height
            
            isFormValid = false
        }
        
        // longitude
        
        if longitudeTextField.text == "" {
            longitudeErrorMessage.hidden = false
            longitudeTopConstraint.constant = 29
            isFormValid = false
        }
        
        // View latitude
        
        if viewLatitudeTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height
            
            isFormValid = false
        }
        
        // View longitude
        
        if viewLongitudeTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height
            
            isFormValid = false
        }
        
        // View tilt
        
        if viewTiltTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height
            
            isFormValid = false
        }
        
        // View roll
        
        if viewRollTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height
            
            isFormValid = false
        }
        
        // View altitude
        
        if viewAltitudeTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height
            
            isFormValid = false
        }
        
        // View heading
        
        if viewHeadingTextField.text == "" {
            // NEEDSWORK: show error label and adjust row height
            
            isFormValid = false
        }
        
        return isFormValid
    }
}
