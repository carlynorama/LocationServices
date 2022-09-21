//
//  LocationService.swift
//  Wind
//
//  Created by Labtanza on 8/9/22.
//

import Foundation
import CoreLocation
import MapKit



public protocol LocationHandler {
    var defaultLocation:CLLocation { get set }
    
    var locationToUse:CLLocation { get }
    var locationName:String { get }
    var lslocationToUse:LSLocation { get }
    
    var deviceLocation:CLLocation? { get }
    var deviceLocality:String? { get }
    
}

//public protocol CLLocationPublisher:LocationHandler {
//    var locationPublisher:Published<CLLocation>.Publisher { get }
//    var locationPublished:Published<CLLocation> { get }
//}

public protocol LSLocationPublisher:LocationHandler {
    var locationPublisher:Published<LSLocation>.Publisher { get }
    var locationPublished:Published<LSLocation> { get }
}

public protocol LocationNotifier:LocationHandler {
    var notificationCenter:NotificationCenter { get }
    var notificationName:Notification.Name { get }
}


public extension LocationHandler {
    
    var latitude:Double { locationToUse.coordinate.latitude }
    var longitude:Double { locationToUse.coordinate.longitude }
    
}

extension LocationHandler {
    
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



