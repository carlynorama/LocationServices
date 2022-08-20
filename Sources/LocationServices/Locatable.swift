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
//    var description:String {
//        "LAT: \(latitude), LONG: \(longitude)"
//    }
    
    var location:CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var placemark:CLPlacemark {
        get async throws {
            try await lookUpPlacemark()
        }
    }
    
    var placemarkDescription:String? {
        get async throws {
            try await lookUpPlacemark().locality
        }
    }
    
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                               -> Void ) {
        // Use the last reported location.
        let location = self.location
        let geocoder = CLGeocoder()
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location,
                                        completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
                // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    
    func lookUpPlacemark() async throws -> CLPlacemark {
        let result = try await CLGeocoder().reverseGeocodeLocation(self.location)
        let firstLocation = result[0]
        return firstLocation
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

