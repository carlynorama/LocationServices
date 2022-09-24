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
        let item = MKMapItem(placemark: MKPlacemark(coordinate: self.location.coordinate))
        item.name = description
        return item
    }
}

public extension LSLocation {
    init?(from placemark:CLPlacemark) {
        if let location = placemark.location {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.timeStamp = Date.now
            
//            self.initializingPlacemark = placemark
            self.description = LocationServices.descriptionFromPlacemark(placemark)
//            self.initializingMKMapItem = nil
//            self.initializingCLLocation = nil
            
        } else {
            return nil
        }

    }
    
    init(cllocation:CLLocation, name:String) {
        self.latitude = cllocation.latitude
        self.longitude = cllocation.longitude
        self.description = name
        self.timeStamp = Date.now
        
//        self.initializingCLLocation = cllocation
//        self.initializingPlacemark = nil
//        self.initializingMKMapItem = nil
    }
    
    init(cllocation:CLLocation) async {
        self.latitude = cllocation.latitude
        self.longitude = cllocation.longitude
        self.description = await LocationServices.descriptionFromCLLocation(for: cllocation)
        self.timeStamp = Date.now
        
//        self.initializingCLLocation = cllocation
//        self.initializingPlacemark = nil
//        self.initializingMKMapItem = nil
    }
    
    //relies of locatable extension
    init?(from mkmapitem:MKMapItem) {
        self.latitude = mkmapitem.placemark.coordinate.latitude
        self.longitude = mkmapitem.placemark.coordinate.longitude
        self.description = LocationServices.descriptionFromMapItem(mkmapitem)
        self.timeStamp = Date.now
        
//        self.initializingMKMapItem = mkmapitem
//        self.initializingCLLocation = nil
//        self.initializingPlacemark = nil
    }
}

//
//public extension LSLocation {
//    var cllocation:CLLocation {
//        if let initializingCLLocation {
//            return initializingCLLocation
//        } else {
//            return CLLocation(latitude: latitude, longitude: longitude)
//        }
//    }
//
//    var placemark:CLPlacemark {
//        get async throws {
//            if let initializingPlacemark {
//                return initializingPlacemark
//            } else {
//                return try await lookUpPlacemark()
//            }
//        }
//    }
//
//}

