//
//  File.swift
//  
//
//  Created by Labtanza on 8/11/22.
//

import Foundation
import CoreLocation
import MapKit


public struct LSLocation:Locatable, Hashable, Identifiable, Codable, Sendable {
    public let latitude:Double
    public let longitude:Double
    public let description:String
    public let timeStamp:Date
    
    public var id:String {
        "\(latitude)+\(longitude)+\(timeStamp)"
    }
  
      //TODO: Save _the fields_
    //It's moe important the it be Codeable and Sendable at this time
    //than retain all possible data.
//    public let initializingCLLocation:CLLocation?
//    public let initializingPlacemark:CLPlacemark?
//    public let initializingMKMapItem:MKMapItem?

    public init(latitude: Double, longitude: Double, description: String, time:Date = Date.now) {
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.timeStamp = time
//        self.initializingCLLocation = nil
//        self.initializingPlacemark = nil
//        self.initializingMKMapItem = nil
    }
    
    public func compare(_ rhs:LSLocation) -> (cordinatesEqual:Bool, contentEqual:Bool, timeStampDif:TimeInterval) {
        return (compareCoordinates(rhs), compareContent(rhs), compareTimeStamps(rhs))
    }
    
    func compareCoordinates(_ rhs:LSLocation) -> Bool {
        self.latitude == rhs.latitude && self.longitude == rhs.longitude
    }
    
    func compareContent(_ rhs:LSLocation) -> Bool {
        self.description == rhs.description
    }
    
    func compareTimeStamps(_ rhs:LSLocation) -> TimeInterval {
        self.timeStamp.timeIntervalSinceReferenceDate - rhs.timeStamp.timeIntervalSinceReferenceDate
    }
}


public extension LSLocation {
    static func locationsForPlacemarks(_ placemarks:[CLPlacemark]) -> [LSLocation]{
        LocationServices.locationsForPlacemarks(placemarks)
    }
}
