//
//  LocationStore.swift
//  Wind
//
//  Created by Carlyn Maw on 6/24/22.
//
// More Locations? https://www.kurzwind.com/9-windiest-cities/
// Barrow Island, Australia
// Cape Blanco, Oregon
// Ab-Paran, Afghanistan
// Gruissan, France

import Foundation
import CoreLocation



public final class LocationStore {
    
    public init() {}
    
    var sessionLocationHistory:[LSLocation] = []
    
    let defaults = UserDefaults.standard
    let currentLocationKey = "currentLocationKey"
    let storedLocationsKey = "storedLocations"
    
    func currentLocationSave(_ location:LSLocation) {
        defaults.set(location, forKey: currentLocationKey)
    }
    
    func mostRecentLocationsSave(_ locations:[LSLocation]) {
        let toStore = locations.sorted(by: { $0.timeStamp > $1.timeStamp }).prefix(5)
        defaults.set(toStore, forKey: "recentLocations")
    }
    
    func storedCurrentLocation() -> LSLocation? {
        defaults.object(forKey: currentLocationKey) as? LSLocation
    }
    
    func storedRecentLocations() -> [LSLocation]? {
        defaults.object(forKey: storedLocationsKey) as? [LSLocation]
    }
    
}

extension LocationStore {
    static var shared = LocationStore()
    
    public static let defaultLSLocation =
        LSLocation(
            latitude: 34.0536909,
            longitude: -118.242766,
            description: "Los Angeles, CA, United States")
    
    public static let defaultCLLocation:CLLocation =
        CLLocation(
            latitude: 34.0536909,
            longitude: -118.242766)
    
    
    public static let locations = [
        LSLocation(
            latitude: 34.0536909,
            longitude: -118.242766,
            description: "Los Angeles, CA, United States"),
        LSLocation(
            latitude: 25.7959,
            longitude: -80.2871,
            description: "Miami, FL, United States"),
        LSLocation(
            latitude: 41.8755616,
            longitude: -87.6244212,
            description: "Chicago, IL, United States"),
        LSLocation(
            latitude: -41.286461,
            longitude: 174.776230,
            description: "Wellington, New Zealand"),
        LSLocation(
            latitude: -51.630920,
            longitude: -69.224777,
            description: "Rio Gallegos, Argentina"),
        LSLocation(
            latitude: 47.562670,
            longitude: -52.710890,
            description: "St. Johns, NL, Canada"),
        LSLocation(
            latitude: -53.161968,
            longitude: -70.909561,
            description: "Punta Arenas, Chile"),
        LSLocation(
            latitude: 37.765470,
            longitude: -100.015170,
            description: "Dodge City, KS, United States"),
        LSLocation(
            latitude: 3.52559,
            longitude: 36.0745062,
            description: "Lake Turkana, Marsabit County, Kenya"),
        LSLocation(
            latitude: -66.9000,
            longitude: 142.6667,
            description: "Commonwealth Bay, Antarctica"),
        LSLocation(
            latitude: 47.3686498,
            longitude: 8.5391825,
            description: "Zürich"),
        LSLocation(
            latitude: -8.7467,
            longitude: 115.1668,
            description: "Bali")
    ]
}

