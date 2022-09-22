//
//  File.swift
//  
//
//  Created by Labtanza on 9/21/22.
//

import Foundation
import CoreLocation


@MainActor
public final class LocationProvider:ObservableObject {
    let locationStore:LocationStore
    let deviceLocation:DeviceLocationManager
    
    @Published public var locationToUse:LSLocation
    
    public init(locationStore:LocationStore, deviceLocationManager:DeviceLocationManager) {
        self.locationStore = locationStore
        self.deviceLocation = deviceLocationManager
        self.locationToUse = locationStore.storedCurrentLocation() ?? LocationStore.defaultLSLocation
        loadHistory()
    }
    
    public var locationPublisher:Published<LSLocation>.Publisher {
        $locationToUse
    }
    public var locationPublished:Published<LSLocation> {
        _locationToUse
    }

    public func requestDeviceLocation() async {
        print("request triggered")
        status = .pending
        guard deviceLocation.status != .requesting else {
            print("request already in progress.")
            return
        }
        print("new device location request.")
        if let newLocation = try? await deviceLocation.requestLocation() {
            print("Location recieved, finding description.")
            let newLSLocaiton = await LSLocation(cllocation: newLocation)
            
            if newLSLocaiton == locationToUse {
            //if newLSLocaiton.compareCoordinates(locationToUse) {
                print("still in the same spot")
                status = .success
            } else {
                updateLocation(newLSLocaiton)
            }
        } else {
            print("Device location not returned.")
            status = .failed
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
        updateStorage(location)
        status = .success
        print("Location updated.")
    }
    
    @Published public private(set) var recentLocations:Set<LSLocation> = []
    
    func loadHistory() {
        print("loading history")
        locationStore.loadHistory()
        recentLocations = locationStore.sessionLocationHistory
    }
    
    func updateStorage(_ loc:LSLocation) {
        print("updating storage")
        recentLocations.insert(loc)
        locationStore.currentLocationSave(loc)
        locationStore.appendLocationToHistory(loc)
    }
    
    public func clearHistory() {
        locationStore.clearSavedHistory()
        recentLocations = []
    }
    

    
    
    public enum RequestStatus {
        case pending
        case success
        case norequestyet
        case failed
    }
    
    public var status:RequestStatus = .norequestyet
    
}





