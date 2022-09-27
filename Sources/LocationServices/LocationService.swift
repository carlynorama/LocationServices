//
//  File.swift
//  
//
//  Created by Labtanza on 9/21/22.
//

import Foundation
import CoreLocation


@MainActor
public final class LocationService:ObservableObject {
    let locationStore:LocationStore
    let deviceLocationManager:DeviceLocationManager
    
    @Published public var locationToUse:LSLocation = LocationStore.defaultLSLocation
    @Published public private(set) var recentLocations:Set<LSLocation> = []
    
    nonisolated public init(locationStore:LocationStore, deviceLocationManager:DeviceLocationManager) {
        self.locationStore = locationStore
        self.deviceLocationManager = deviceLocationManager
        Task { await loadCurrentLocation() }
        Task { await loadHistory() }
    }
    
    nonisolated public init() {
        self.locationStore = LocationStore()
        self.deviceLocationManager = DeviceLocationManager()
        Task { await loadCurrentLocation() }
        Task { await loadHistory() }
    }
    
    
    public var locationPublisher:Published<LSLocation>.Publisher {
        $locationToUse
    }
    public var locationPublished:Published<LSLocation> {
        _locationToUse
    }
    
    //This stream is behving oddly? updating constantly not just on change?
    //Better to have the reiver establish the stream if necessary.
//    public func locationStream() -> AsyncStream<LSLocation> {
//        return AsyncStream.init(unfolding: unfolding, onCancel: onCancel)
//
//        //() async -> _?
//        func unfolding() async -> LSLocation? {
//            for await location in locationPublisher.values {
//                //print("\(location)")
//                return location
//            }
//            return nil
//        }
//
//        //optional
//        @Sendable func onCancel() -> Void {
//            print("confirm locationStream got canceled")
//        }
//    }
    
    public func retrieveDeviceLocation() async throws -> LSLocation {
        print("request triggered")
        status = .pending
        guard deviceLocationManager.status != .requesting else {
            print("request already in progress.")
            status = .updateFailed
            throw LocationServiceError.locationRequestAlreadyInProgress
        }
        
        print("new device location request.")
        do {
            let newLocation = try await deviceLocationManager.requestLocation()
            //need this to be STRUCTURED. No going further without the results
            print("Location result recieved, finding description.")
            
            if let newLocation {
                status = .locationRecieved
                let newLSLocaiton = await LSLocation(cllocation: newLocation)
                return newLSLocaiton
            } else {
                status = .updateFailed
                throw LocationServiceError.noLocationFromDevice
            }
            
        } catch {
            status = .updateFailed
            throw LocationServiceError.couldNotMakeLocationFromDeviceLocation
        }
    }
    
    public func updateWithDeviceLocation() async throws {
        let newLocation = try await retrieveDeviceLocation()
        
        if newLocation == locationToUse {
            //if newLSLocaiton.compareCoordinates(locationToUse) {
            print("still in the same spot")
            status = .updateSuccess
        } else {
            updateLocation(newLocation)
            //since there isn't anything that can go wrong in
            //update function currently this is okay here.
            status = .updateSuccess
        }
    }
    
    public func startDeviceLocationUpdateAttempt() -> Task<(), Never> {
        Task {
            do {
                try await updateWithDeviceLocation()
            } catch {
                print(error.localizedDescription)
            }
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
        
        print("Location updated.")
    }
    
    func loadCurrentLocation() {
        self.locationToUse = locationStore.storedCurrentLocation() ?? LocationStore.defaultLSLocation
    }
    
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
    
    
    
    
    public enum DeviceLocationRequestStatus {
        case pending
        case updateSuccess
        case norequestyet
        case updateFailed
        case locationRecieved
    }
    
    public var status:DeviceLocationRequestStatus = .norequestyet
    
}

enum LocationServiceError:Error {
    case locationRequestAlreadyInProgress
    case noLocationFromDevice
    case couldNotMakeLocationFromDeviceLocation
}



