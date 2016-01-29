//
//  GeoPlace.swift
//  Map Scriptures
//
//  Created by Steve Liddle on 11/5/14.
//  Copyright (c) 2014 IS 543. All rights reserved.
//

import Foundation
import SQLite

class GeoPlace {
    enum GeoCategory: Int {
        // Categories represent geocoded places we've constructed from various
        // Church history sources (1) or the Open Bible project (2)
        case ChurchHistory = 1,
             OpenBible = 2
    }
    
    enum GeoFlag: String {
        // Flags indicate different levels of certainty in the Open Bible database
        case None = "",
             Open1 = "~",
             Open2 = ">",
             Open3 = "?",
             Open4 = "<",
             Open5 = "+"
    }

    var id: Int
    var placename: String
    var latitude: Double
    var longitude: Double
    var flag: GeoFlag
    var viewLatitude: Double?
    var viewLongitude: Double?
    var viewTilt: Double?
    var viewRoll: Double?
    var viewAltitude: Double?
    var viewHeading: Double?
    var category: GeoCategory!

    init(fromRow: Row) {
        id = fromRow.get(gGeoPlaceId)
        placename = fromRow.get(gGeoPlacePlacename)
        latitude = fromRow.get(gGeoPlaceLatitude)
        longitude = fromRow.get(gGeoPlaceLongitude)
        category = GeoCategory(rawValue: fromRow.get(gGeoPlaceCategory))

        if let geoFlag = fromRow.get(gGeoPlaceFlag) {
            flag = GeoFlag(rawValue: geoFlag)!
        } else {
            flag = GeoFlag.None
        }

        if let vLatitude = fromRow.get(gGeoPlaceViewLatitude) {
            viewLatitude = vLatitude
            viewLongitude = fromRow.get(gGeoPlaceViewLongitude)
            viewTilt = fromRow.get(gGeoPlaceViewTilt)
            viewRoll = fromRow.get(gGeoPlaceViewRoll)
            viewAltitude = fromRow.get(gGeoPlaceViewAltitude)
            viewHeading = fromRow.get(gGeoPlaceViewHeading)
        }
    }
}