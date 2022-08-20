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
    
    public var id:String {
        "\(latitude)+\(longitude)"
    }

}

public extension LSLocation {
    static func locationsForPlacemarks(_ placemarks:[CLPlacemark]) -> [LSLocation]{
        var tmp:[LSLocation?] = []
        for item in placemarks {
            //print(item)
            if let asLocation = LSLocation(from: item) {
                tmp.append(asLocation)
            } else {
                print("Could not turn into Location.")
            }
        }
        return tmp.compactMap { $0 }
    }
}
