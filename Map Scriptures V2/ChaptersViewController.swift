//
//  ChaptersViewController.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 11/12/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit

class ChaptersViewController : UITableViewController {
  
    // MARK: - Properties
    
    var book: Book!
    var chapters = [Int]()
    weak var mapViewController: MapViewController?
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Scripture from Chapter" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let destinationViewController = segue.destinationViewController as? ScriptureViewController {
                    // populates the chapters according to their book as found in the BooksViewController's indexpath
                    destinationViewController.book = book
                    destinationViewController.chapter = chapters[indexPath.row]
                    
                    // set view controller title to show the current chapter selected
                    destinationViewController.title = book.backName + " \(chapters[indexPath.row])"
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChapterCell")!
        
        cell.textLabel?.text = book.backName + " \(chapters[indexPath.row])"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapters.count
    }
}
