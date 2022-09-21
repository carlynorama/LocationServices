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
        self.initializingPlacemark = placemark
        self.description = LocationServices.descriptionFromPlacemark(placemark)
    }
    
    init(cllocation:CLLocation, name:String) {
        self.latitude = cllocation.latitude
        self.longitude = cllocation.longitude
        self.description = name
        
        self.initializingCLLocation = cllocation
    }
    
    //relies of locatable extension
    init?(from mkmapitem:MKMapItem) {
        self.latitude = mkmapitem.placemark.coordinate.latitude
        self.longitude = mkmapitem.placemark.coordinate.longitude
        self.description = LocationServices.descriptionFromMapItem(mkmapitem)
        
        self.initializingMKMapItem = mkmapitem
    }
}
