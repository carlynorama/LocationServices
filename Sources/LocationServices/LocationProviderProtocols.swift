//
//  LocationService.swift
//  Wind
//
//  Created by Labtanza on 8/9/22.
//

import Foundation
import CoreLocation
import MapKit



public protocol LocationBroadcaster {
    var defaultLocation:CLLocation { get set }
    
    var locationToUse:CLLocation { get }
    var locationName:String { get }
    var lslocationToUse:LSLocation { get }
    
    var deviceLocation:CLLocation? { get }
    var deviceLocality:String? { get }
    
}

public protocol LocationPublisher:LocationBroadcaster {
    var locationPublisher:Published<CLLocation>.Publisher { get }
    var locationPublished:Published<CLLocation> { get }
    var lslocationPublisher:Published<LSLocation>.Publisher { get }
    var lslocationPublished:Published<LSLocation> { get }
}


public extension LocationBroadcaster {
    
    var latitude:Double { locationToUse.coordinate.latitude }
    var longitude:Double { locationToUse.coordinate.longitude }
    
}

extension LocationBroadcaster {
    
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



