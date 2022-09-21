import Foundation
import CoreLocation
import MapKit

public enum LocationServices {
    
    public static var defaultLocation:CLLocation {
        LocationStore.locations[0].location
    }
    
    static func placemarkForLocation(_ location:CLLocation) async throws -> CLPlacemark {
        let result = try await CLGeocoder().reverseGeocodeLocation(location)
        let firstLocation = result[0]
        return firstLocation
    }
    
    @available(*, deprecated, message: "Use async call instead.")
    static func placemarkForLocation(_ location:CLLocation, completionHandler: @escaping (CLPlacemark?)
                                     -> Void ) {
        let geocoder = CLGeocoder()
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location,
                                        completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
                // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
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
    
    static func locationsForPlacemarks(_ placemarks:[CLPlacemark]) -> [LSLocation]{
        var tmp:[LSLocation?] = []
        for item in placemarks {
            //print(item)
            if let asLocation = LSLocation(from: item) {
                tmp.append(asLocation)
            } else {
                print("Could not turn into Location.")
            }
        }
        return tmp.compactMap { $0 }
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
    
    static func dms(for number:some BinaryFloatingPoint) -> (degrees: Int, minutes: Int, seconds: Int, isPositive:Bool) {
        let isPositive = number >= 0
        let totalSeconds = abs(number * 3600)
        let degrees = Int(totalSeconds / 3600)
        let remainder = totalSeconds.truncatingRemainder(dividingBy: 3600)
        //also remainder = totalSeconds % 3600) if int conversion then
        //TODO: Compare performance?
        let minutes = Int(remainder / 60)
        let seconds = Int(remainder.truncatingRemainder(dividingBy: 60))
        return (degrees, minutes, seconds, isPositive)
    }
    
    static func latitudeString(for number:some BinaryFloatingPoint) -> String {
        let (degrees, minutes, seconds, isPositive) = Self.dms(for: number)
        return String(format: "%@ %d°%d'%d\"", isPositive ? "N" : "S", abs(degrees), minutes, seconds)
    }
    
    static func longitudeString(for number:some BinaryFloatingPoint) -> String {
        let (degrees, minutes, seconds, isPositive) = Self.dms(for: number)
        return String(format: "%@ %%d°%d'%d\"", isPositive ? "E" : "W", abs(degrees), minutes, seconds)
    }
    
    
    
}
