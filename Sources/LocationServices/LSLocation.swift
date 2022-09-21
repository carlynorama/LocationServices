//
//  File.swift
//  
//
//  Created by Labtanza on 8/11/22.
//

import Foundation
import CoreLocation
import MapKit


public struct LSLocation:Locatable, Hashable, Identifiable {
    public let latitude:Double
    public let longitude:Double
    public let description:String
    public let timeStamp:Date
    
    public var id:String {
        "\(latitude)+\(longitude)"
    }
    
    public let initializingCLLocation:CLLocation?
    public let initializingPlacemark:CLPlacemark?
    public let initializingMKMapItem:MKMapItem?

    init(latitude: Double, longitude: Double, description: String, time:Date = Date.now) {
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.timeStamp = time
        self.initializingCLLocation = nil
        self.initializingPlacemark = nil
        self.initializingMKMapItem = nil
    }
    
    public var sendable:(latitude:Double, longitude:Double, description:String, timeStamp:Date) {
        return (latitude, longitude, description, timeStamp)
    }
    
}

public extension LSLocation {
    var cllocation:CLLocation {
        if let initializingCLLocation {
            return initializingCLLocation
        } else {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    var placemark:CLPlacemark {
        get async throws {
            if let initializingPlacemark {
                return initializingPlacemark
            } else {
                return try await lookUpPlacemark()
            }
        }
    }
    
}


public extension LSLocation {
    static func locationsForPlacemarks(_ placemarks:[CLPlacemark]) -> [LSLocation]{
        LocationServices.locationsForPlacemarks(placemarks)
    }
}
