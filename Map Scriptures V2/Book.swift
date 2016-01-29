//
//  Book.swift
//  Map Scriptures
//
//  Created by Steve Liddle on 11/5/14.
//  Copyright (c) 2014 IS 543. All rights reserved.
//

import Foundation
import SQLite

class Book {
    var id: Int
    var abbr: String
    var citeAbbr: String
    var fullName: String
    var numChapters: Int?
    var parentBookId: Int?
    var webTitle: String
    var tocName: String
    var subdiv: String?
    var backName: String
    var gridName: String
    var citeFull: String
    var heading2: String

    init(fromRow: Row) {
        id = fromRow.get(gBookId)
        abbr = fromRow.get(gBookAbbr)
        citeAbbr = fromRow.get(gBookCiteAbbr)
        citeFull = fromRow.get(gBookCiteFull)
        fullName = fromRow.get(gBookFullName)
        numChapters = fromRow.get(gBookNumChapters)
        parentBookId = fromRow.get(gBookParentBookId)
        webTitle = fromRow.get(gBookWebTitle)
        tocName = fromRow.get(gBookTocName)
        subdiv = fromRow.get(gBookSubdiv)
        backName = fromRow.get(gBookBackName)
        gridName = fromRow.get(gBookGridName)
        heading2 = fromRow.get(gBookHeading2)
    }
}