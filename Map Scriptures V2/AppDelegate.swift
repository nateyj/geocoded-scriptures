//
//  AppDelegate.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 11/12/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    // MARK: - Properties
    
    var window: UIWindow?

    
    // MARK: - Application lifecycle

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers.last as! UINavigationController
        
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
            
        UIMenuController.sharedMenuController().menuItems = [UIMenuItem(title: "Suggest Geocoding", action: "suggestGeocoding:")]
        
        return true
    }

    
    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController:UIViewController,
        ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let _ = secondaryAsNavController.topViewController as? MapViewController else { return false }
        
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController,
        separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        
        if let navigationViewController = primaryViewController as? UINavigationController {
            for controller in navigationViewController.viewControllers {
                if let controllerViewController = controller as? UINavigationController {
                    // we found our detail view controller on the master view controller stack
                    return controllerViewController
                }
            }
        }
        
        // we didn't find our detail view controller on the master view controller stack, so we need to instantiate it
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailView = storyboard.instantiateViewControllerWithIdentifier("detailVC") as! UINavigationController
            
            // ensure back button is enabled
            if let controller = detailView.visibleViewController {
                // allows user to hide the master view controller by pushing on a button
                controller.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
                
                // if we wanted to have an array of things in the left bar button, it's possible now
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        
        return detailView
    }
}

