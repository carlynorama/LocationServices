//
//  File.swift
//  
//
//  Created by Labtanza on 9/21/22.
//

import Foundation
import CoreLocation


class LocationProvider {
    
//    @Published public var deviceLocation:CLLocation?
//    @Published public var deviceLocality:String?
    
    public var defaultLocation:CLLocation = CLLocation(latitude: 34.0536909,
                                                       longitude: -118.242766)
    
    //TODO:Check user defaults for a saved defaultLocation, add to init? static builder?
    @Published public var locationToUse:CLLocation = CLLocation(latitude: 34.0536909,
                                                                longitude: -118.242766)
    @Published public var locationName:String = "Default Location"
    
    @Published public var lslocationToUse:LSLocation = LSLocation(coordinates: CLLocation(latitude: 34.0536909,longitude: -118.242766), name: "Start Location")
    
    //    static func determineLocationToUse(_ location:CLLocation? = nil) -> CLLocation {
    //        if let loc = location {
    //            return loc
    //        } else {
    //            //TODO: Look in user defaults.
    //            return CLLocation(latitude: 34.0536909,
    //                                      longitude: -118.242766)
    //        }
    //    }
    
    public var locationPublisher:Published<CLLocation>.Publisher {
        $locationToUse
    }
    public var locationPublished:Published<CLLocation> {
        _locationToUse
    }
    
    public var lslocationPublisher:Published<LSLocation>.Publisher {
        $lslocationToUse
    }
    public var lslocationPublished:Published<LSLocation> {
        _lslocationToUse
    }
    
//    var locationHistory:[LSLocation] = [LSLocation(coordinates: CLLocation(latitude: 34.0536909,
//                                                                           longitude: -118.242766), name: "Start Location")]
//
}

//MARK: Getting Descriptions
extension LocationProvider {

    
    func updateDescription() {
        Task {
            do {
                await MainActor.run {
                    self.locationName = "..."
                }
                let placemark = try await LocationServices.placemarkForLocation(locationToUse)
                let string = LocationServices.descriptionFromPlacemark(placemark)
                
                await MainActor.run {
                    self.locationName =  string//?? "No place name available"
                }
                await MainActor.run {
                    lslocationToUse = LSLocation(coordinates: locationToUse, name: locationName)
                }
                
            } catch {
                print("LM updateDescription: couldn't find locality")
            }
        }
    }
    
    public func updateLocationToUse(lat:Double, long:Double) {
        //TODO: save to user defaults
        let newLocation = CLLocation(latitude: lat, longitude: long)
        
        self.defaultLocation = newLocation
        self.locationToUse = newLocation
        updateDescription()
    }
    
    public func updateLocationToUse(_ location:LSLocation) {
        self.locationToUse = location.location
        self.locationName = location.description
    }
    
    
    func updateStoredLocations(_ location:) async {
        updateLocality()
        if let loc = deviceLocation {
            locationToUse = loc
        } else {
            locationToUse = defaultLocation
        }
        updateDescription()
    }
    
}





