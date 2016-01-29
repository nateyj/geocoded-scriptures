//
//  BooksViewController.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 11/12/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit

class BooksViewController : UITableViewController {
    
    // MARK: constants
    
    let SCRIPTURE_SEGUE = "Show Scripture"
    let CHAPTER_SEGUE = "Show Chapters"
    
    
    // MARK: Properties
    
    var books: [Book]!
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SCRIPTURE_SEGUE  {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destinationViewController = segue.destinationViewController as? ScriptureViewController {
                    destinationViewController.book = books[indexPath.row]
                    // don't need to set the chapter, because if the logic gets to this point, the book has no chapters

                    // set view controller title to show the selected chapter
                    destinationViewController.title = books[indexPath.row].fullName
                }
            }
        }
        
        if segue.identifier == CHAPTER_SEGUE {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destinationViewController = segue.destinationViewController as? ChaptersViewController {
                    if let numChapters = books[indexPath.row].numChapters {
                        if numChapters > 0 {
                            // add to the chapter array the number of chapters in the book
                            for chapter in 1...numChapters {
                                destinationViewController.chapters.append(chapter)
                            }
                        }
                        
                        // add book to ChapterViewController so it can be passed on to ScriptureViewController
                        destinationViewController.book = books[indexPath.row]
                    }
                    
                    // set view controller title to show the selected chapter
                    destinationViewController.title = books[indexPath.row].fullName
                }
            }
        }
    }
    
    
    // MARK: Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell")!
        
        cell.textLabel?.text = books[indexPath.row].fullName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    
    // MARK: Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if a book has no chapters (e.g., Title Page) then go straight to ScriptureViewController
        if books[indexPath.row].numChapters == nil {
            performSegueWithIdentifier(SCRIPTURE_SEGUE, sender: self)
        } else {
            performSegueWithIdentifier(CHAPTER_SEGUE, sender: self)
        }
    }
}
