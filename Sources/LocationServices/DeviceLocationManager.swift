//
//  File.swift
//  
//
//  Created by Labtanza on 8/9/22.
//

import Foundation
import CoreLocation
import MapKit



public final class DeviceLocationManager: NSObject  {
    public static let shared = DeviceLocationManager()
    
    let manager = CLLocationManager()
    var locationContinuation: CheckedContinuation<CLLocation?, Error>?
    
    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
        manager.requestWhenInUseAuthorization()
    }
    
    
}

extension DeviceLocationManager:CLLocationManagerDelegate {
   
    
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
    
    public func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        locationContinuation?.resume(returning: locations.first)
    }
    
    public func locationManager(_ manager:CLLocationManager, didFailWithError error:Error) {
        locationContinuation?.resume(throwing: error)
    }
    
    @available(*, deprecated, message: "Use async instead")
    public func requestLocation() {
        manager.requestLocation()
    }
    
    func requestLocation() async throws -> CLLocation? {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    func retrieveLocality() async -> String? {
        if let loc = deviceLocation {
            do {
                async let placemark = try LocationServices.placemarkForLocation(loc)
                return try await placemark.locality
            } catch {
                print("LM updateLocality: couldn't find locality")
            }
        }
    }
}


