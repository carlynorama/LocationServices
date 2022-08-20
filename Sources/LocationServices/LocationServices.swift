import Foundation
import CoreLocation
import MapKit

public struct LocationServices {
    public init() {
    }
    
    static var defaultLocation:CLLocation {
        LocationStore.locations[0].location
    }
    
    static func placemarkForLocation(_ location:CLLocation) async throws -> CLPlacemark {
        let result = try await CLGeocoder().reverseGeocodeLocation(location)
        let firstLocation = result[0]
        return firstLocation
    }
    
    
    static func locationForString(_ addressString:String) async throws -> CLLocation? {
        let result = try await CLGeocoder().geocodeAddressString(addressString)
        let firstPlaceMark = result[0]
        return firstPlaceMark.location
        //func geocodeAddressString(_ addressString: String) async throws -> [CLPlacemark]
    }
    
    static func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
        let firstItem = placemark.locality //placemark.areasOfInterest?[0] ?? placemark.locality
        let availableInfo:[String?] = [firstItem, placemark.administrativeArea, placemark.country]
        let string = availableInfo.compactMap{ $0 }.joined(separator: ", ")
        return string
    }
    
    static func descriptionFromMapItem(_ mkmapitem:MKMapItem) -> String {
        String([mkmapitem.name, mkmapitem.placemark.administrativeArea, mkmapitem.placemark.country].compactMap({$0}).joined(separator: ", "))
    }
    
    
    //    static func descriptionFromLocation(_ location:CLLocation) -> String {
    //        Task {
    //            do {
    //                let placemark = try await Self.placemarkForLocation(location)
    //                let string = Self.descriptionFromPlacemark(placemark)
    //                DispatchQueue.main.async {
    //                    return string//?? "No place name available"
    //                }
    //
    //            } catch {
    //                print("LM updateDescription: couldn't find locality")
    //            }
    //        }
    //    }
    
}
