//
//  LocationService.swift
//  Wind
//
//  Created by Labtanza on 8/9/22.
//

import Foundation
import CoreLocation
import MapKit


//public protocol LocationService:ObservableObject {
public protocol LocationBroadcaster {
    var defaultLocation:CLLocation { get set }
    var locationToUse:CLLocation { get }
    var locationName:String { get }
    var deviceLocation:CLLocation? { get }
    var deviceLocality:String? { get }
}

public protocol LocationPublisher:LocationBroadcaster & ObservableObject {
    var locationPublisher:Published<CLLocation>.Publisher { get }
    var locationPublished: Published<CLLocation> { get }
}

public protocol LocationStreamer:LocationBroadcaster {
    var locationStream:AsyncStream<LSLocation> { get }
}

public extension LocationBroadcaster {
    
    var latitude:Double { locationToUse.coordinate.latitude }
    var longitude:Double { locationToUse.coordinate.longitude }
    
    // TODO:Returns a string that is a location in memory?
    //    var description:String? {
    //        get async throws {
    //            try await Self.placemarkForLocation(self.locationToUse).locality
    //        }
    //    }
    
    static func placemarkForLocation(_ location:CLLocation) async throws -> CLPlacemark {
        try await LocationServices.placemarkForLocation(location)
    }
    
    
    static func locationForString(_ addressString:String) async throws -> CLLocation? {
        try await LocationServices.locationForString(addressString)
    }
    
    static func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
        LocationServices.descriptionFromPlacemark(placemark)
    }
}

public extension LocationStreamer {
    
}

