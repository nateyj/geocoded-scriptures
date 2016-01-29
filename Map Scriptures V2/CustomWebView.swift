//
//  CustomWebView.swift
//  Map Scriptures
//
//  Created by Nathan Johnson on 12/2/15.
//  Copyright © 2015 Nathan Johnson. All rights reserved.
//

import UIKit

protocol SuggestionDisplayDelegate {
    func displaySuggestionDialog()
}

class CustomWebView : UIWebView {
    var suggestionDelegate: SuggestionDisplayDelegate?
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "suggestGeocoding:" {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    func suggestGeocoding(sender: AnyObject?) {
        suggestionDelegate?.displaySuggestionDialog()
    }
}
