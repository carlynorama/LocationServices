//
//  File.swift
//  
//
//  Created by Labtanza on 9/21/22.
//

import Foundation
import CoreLocation


public final class LocationProvider:ObservableObject {
    let locationStore:LocationStore
    let deviceLocation:DeviceLocationManager
    
    @Published public var locationToUse:LSLocation
    
    public init(locationStore:LocationStore, deviceLocationManager:DeviceLocationManager) {
        self.locationStore = locationStore
        self.deviceLocation = deviceLocationManager
        self.locationToUse = locationStore.storedCurrentLocation() ?? LocationStore.defaultLSLocation
    }
    
    public var locationPublisher:Published<LSLocation>.Publisher {
        $locationToUse
    }
    public var locationPublished:Published<LSLocation> {
        _locationToUse
    }

    public func requestDeviceLocation() async {
        if let newLocation = try? await deviceLocation.requestLocation() {
            async let newLSLocaiton = LSLocation(cllocation: newLocation)
            updateLocation(await newLSLocaiton)
        }
    }
    
    public func updateLocation(lat:Double, long:Double) async {
        let newLocation = CLLocation(latitude: lat, longitude: long)
        let newLSLocation = LSLocation(cllocation: newLocation, name: await LocationServices.descriptionFromCLLocation(for: newLocation))
        updateLocation(newLSLocation)
    }
    
    public func updateLocation(lat:Double, long:Double, name:String) {
        let newLSLocation = LSLocation(cllocation: CLLocation(latitude: lat, longitude: long), name: name)
        updateLocation(newLSLocation)
    }
    
    public func updateLocation(cllocation: CLLocation, name: String) {
        let newLSLocation = LSLocation(cllocation: cllocation, name: name)
        updateLocation(newLSLocation)
    }
    
    public func updateLocation(_ location:LSLocation)  {
        self.locationToUse = location
        locationStore.currentLocationSave(location)
        locationStore.sessionLocationHistory.append(location)
    }
    
}





