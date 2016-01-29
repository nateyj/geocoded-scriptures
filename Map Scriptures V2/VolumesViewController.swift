//
//  VolumesViewController.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 11/12/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit

class VolumesViewController : UITableViewController {

    // MARK: - Properties
    
    let volumes = GeoDatabase.sharedGeoDatabase.volumes()
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Books" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let destinationViewController = segue.destinationViewController as? BooksViewController {
                    // populates the books according to their volume as found in the VolumesViewController's indexpath
                    destinationViewController.books = GeoDatabase.sharedGeoDatabase.booksForParentId(indexPath.row + 1)
                    
                    // set view controller title to show the current volume selected
                    destinationViewController.title = volumes[indexPath.row]
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VolumeCell")!
        
        cell.textLabel?.text = volumes[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volumes.count
    }
}
