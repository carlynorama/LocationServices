//
//  File.swift
//  
//
//  Created by Labtanza on 8/9/22.
//

import Foundation
import CoreLocation
import MapKit



public final class DeviceLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject  {
    var locationContinuation: CheckedContinuation<CLLocation?, Error>?
    let manager = CLLocationManager()
    
    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
        manager.requestWhenInUseAuthorization()
    }
    
    public func requestLocation() async throws -> CLLocation? {
        status = .requesting
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        status = .success
        locationContinuation?.resume(returning: locations.first)
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        status = .failed
        print(error.localizedDescription)
        locationContinuation?.resume(throwing: error)
        
    }
    
    public func locationManager(_ manager:CLLocationManager,
                                didChangeAuthorization status:CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined         : print("notDetermined")        // location permission not asked for yet
        case .authorizedWhenInUse   : print("authorizedWhenInUse")  // location authorized
        case .authorizedAlways      : print("authorizedAlways")     // location authorized
        case .restricted            : print("restricted")           // TODO: handle
        case .denied                : print("denied")               // TODO: handle
        @unknown default            : fatalError()
        }
    }
    
    public var isEnabled:Bool? {
        switch manager.authorizationStatus {
        case .restricted, .denied:
            return false
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined: // The user hasn’t chosen an authorization status
            return nil
        @unknown default:
            fatalError()
        }
    }
    
    public enum RequestStatus {
        case requesting
        case success
        case norequestyet
        case failed
    }
    
    public var status:RequestStatus = .norequestyet
}


