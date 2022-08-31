//
//  File.swift
//  
//
//  Created by Labtanza on 8/19/22.
//

import Foundation
import CoreLocation
import MapKit


public extension Locatable {
    func asMapItem() -> MKMapItem {
        //This can fail badly.
        MKMapItem(placemark: MKPlacemark(coordinate: self.location.coordinate))
    }
}

public extension LSLocation {
    init?(from placemark:CLPlacemark) {
        if let location = placemark.location {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        } else {
            return nil
        }
        
        self.description = LocationServices.descriptionFromPlacemark(placemark)
    }
    
    init(coordinates:CLLocation, name:String) {
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
        self.description = name
    }
    
    //relies of locatable extension
    init?(from mkmapitem:MKMapItem) {
        self.latitude = mkmapitem.placemark.coordinate.latitude
        self.longitude = mkmapitem.placemark.coordinate.longitude
        self.description = LocationServices.descriptionFromMapItem(mkmapitem)
    }
}
