//
//  File.swift
//
//
//  Created by Labtanza on 8/12/22.
//

import Foundation
import CoreLocation

#if DEBUG
public class LoremIpsunLocationSetAmmet:LocationService {
    public var defaultLocation = CLLocation(latitude: 34.0536909,
                                            longitude: -118.242766)
    @Published public var locationToUse:CLLocation = CLLocation(latitude: 34.0536909,
                                                                longitude: -118.242766)
    
    public var locationPublisher:Published<CLLocation>.Publisher {
        $locationToUse
    }
    public var locationPublished:Published<CLLocation> {
        _locationToUse
    }
    public var deviceLocation:CLLocation? = nil
    
    public func updateLocationToUse(lat:Double, long:Double) {
        if let newLocation = Self.locations.first(where: { $0.latitude == lat }) {
            locationToUse = newLocation.location
        } else {
            locationToUse = defaultLocation
        }
    }
    
    
//    var currentIndex = 0
//    var currentLocation:Location {
//        Self.locations[currentIndex]
//    }
    

    public static let locations = [
        Location(
            latitude: 34.0536909,
            longitude: -118.242766,
            description: "Los Angeles, CA, United States"),
        Location(
            latitude: 25.7959,
            longitude: -80.2871,
            description: "Miami, FL, United States"),
        Location(
            latitude: 41.8755616,
            longitude: -87.6244212,
            description: "Chicago, IL, United States"),
        Location(
            latitude: -41.286461,
            longitude: 174.776230,
            description: "Wellington, New Zealand"),
        Location(
            latitude: -51.630920,
            longitude: -69.224777,
            description: "Rio Gallegos, Argentina"),
        Location(
            latitude: 47.562670,
            longitude: -52.710890,
            description: "St. Johns, NL, Canada"),
        Location(
            latitude: -53.161968,
            longitude: -70.909561,
            description: "Punta Arenas, Chile"),
        Location(
            latitude: 37.765470,
            longitude: -100.015170,
            description: "Dodge City, KS, United States"),
        Location(
            latitude: 3.52559,
            longitude: 36.0745062,
            description: "Lake Turkana, Marsabit County, Kenya"),
        Location(
            latitude: -66.9000,
            longitude: 142.6667,
            description: "Commonwealth Bay, Antarctica"),
        Location(
            latitude: 47.3686498,
            longitude: 8.5391825,
            description: "Zürich"),
        Location(
            latitude: -8.7467,
            longitude: 115.1668,
            description: "Bali")
    ]
}

#endif
