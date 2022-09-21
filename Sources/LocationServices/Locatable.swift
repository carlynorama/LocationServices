//
//  Location.swift
//  Wind
//
//  Created by Carlyn Maw on 6/24/22.
//

import CoreLocation
import MapKit

public protocol Locatable:Hashable, CustomStringConvertible {
    var latitude:Double {get}
    var longitude:Double {get}
}

public extension Locatable {
  
    //Example on how to conform with identifiable
//    public var id:String {
//        "\(latitude)+\(longitude)"
//    }
    
    var coordinateString:String {
        "lat: \(latitude.formatted(.number.precision(.fractionLength(4)))), long: \(longitude.formatted(.number.regex.))"
    }
    
    var location:CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    
    func lookUpPlacemark() async throws -> CLPlacemark {
        try await LocationServices.placemarkForLocation(self.location)
    }
    
    func placemarkDescription() async throws -> String? {
        try await LocationServices.placemarkForLocation(self.location).locality
    }
    
}


extension CLLocation:Locatable {
    public var latitude: Double {
        self.coordinate.latitude
    }
    
    public var longitude: Double {
        self.coordinate.longitude
    }
    
    public var location:CLLocation {
        self
    }
}

extension MKMapItem:Locatable {
    public var latitude:Double {
        self.placemark.location.coordinate.latitude
    }
    
    public var longitude:Double {
        self.placemark.location.coordinate.latitude
    }
    
    public var location:CLLocation {
        self.placemark.location
    }
    
}

extension CLPlacemark:Locatable {
    public var latitude:Double {
        self.location.coordinate.latitude
    }
    
    public var longitude:Double {
        self.location.coordinate.latitude
    }
}

