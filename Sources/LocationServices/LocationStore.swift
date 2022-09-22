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
    public init() {
        
    }
    
    
//    private(set) var saveHistory:Bool = false
//
//    func turnOnHistory() {
//        saveHistory = true
//    }
//
//    func turnOffHistory() {
//        saveHistory = false
//        defaults.removeObject(forKey: storedLocationsKey)
//    }
    
    private(set) var sessionLocationHistory:[LSLocation] = []
    
    let defaults = UserDefaults.standard
    let currentLocationKey = "currentLocationKey"
    let storedLocationsKey = "storedLocations"
    
    func currentLocationSave(_ location:LSLocation) {
        do {
            try defaults.setCustom(location, forKey: currentLocationKey)
        } catch {
            print(error)
        }
    }
    
    private func storeRecentLocations(_ locations:[LSLocation]) {
        let toStore = Array(locations.sorted(by: { $0.timeStamp > $1.timeStamp }).prefix(5))
        do {
            print("storing: \(toStore)")
            try defaults.setCustom(toStore, forKey: storedLocationsKey)
        } catch {
            print(error)
        }
    }
    
    func storedCurrentLocation() -> LSLocation? {
        do {
            return try defaults.getCustom(forKey: currentLocationKey, as: LSLocation.self)
        } catch {
            print(error)
            return nil
        }
    }
    
    private func storedRecentLocations() -> [LSLocation]? {
        print("retrieving")
        do {
            return try defaults.getCustom(forKey: storedLocationsKey, as: [LSLocation].self)
        } catch {
            print(error)
            return nil
        }
    }
    
    func appendLocationToHistory(_ loc:LSLocation) {
        sessionLocationHistory.append(loc)
        storeRecentLocations(sessionLocationHistory)
    }
    
    func loadHistory() {
        if let stored = storedRecentLocations() {
            print("retrieved")
            sessionLocationHistory = stored
        }
    }
    
//    enum LocationStoreErrors:Error {
//        case historyOff
//    }
    
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

