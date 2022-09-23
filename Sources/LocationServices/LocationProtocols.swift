//
//  LocationService.swift
//  Wind
//
//  Created by Labtanza on 8/9/22.
//

import Foundation
import CoreLocation
import MapKit



public protocol LocationProvider {
    var locationToUse:LSLocation { get }
}

public protocol LocationHistoryProvider {
    var recentLocations:Set<LSLocation> { get }
}


public protocol LocationPublisher:LocationProvider {
    var locationPublisher:Published<LSLocation>.Publisher { get }
    var locationPublished:Published<LSLocation> { get }
}

public protocol LocationHistoryPublisher:LocationProvider, LocationHistoryProvider {
    var locationHistoryPublisher:Published<[LSLocation]>.Publisher { get }
    var locationHistoryPublished:Published<[LSLocation]> { get }
}

public protocol LocationNotifier:LocationProvider {
    var notificationCenter:NotificationCenter { get }
    var notificationName:Notification.Name { get }
}


public extension LocationProvider {
    
    var latitude:Double { locationToUse.latitude }
    var longitude:Double { locationToUse.longitude }
    
}

extension LocationProvider {
    
    func placemarkForLocation(_ location:CLLocation) async throws -> CLPlacemark {
        try await LocationServices.placemarkForLocation(location)
    }
    
    
    func locationForString(_ addressString:String) async throws -> CLLocation? {
        try await LocationServices.locationForString(addressString)
    }
    
    func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
        LocationServices.descriptionFromPlacemark(placemark)
    }
}



