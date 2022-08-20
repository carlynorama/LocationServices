//
//  RowViews.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI
import MapKit
import CoreLocationUI


public struct MapItemRow:View {
    public init(item:MKMapItem) {
        self.item = item
    }
    
    let item:MKMapItem
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name ?? "No name provided")
                Text(descriptionFromPlacemark(item.placemark))
                HStack {
                    Text("\(item.placemark.coordinate.latitude)" )
                    Text("\(item.placemark.coordinate.longitude)" )
                }
            }
        }
    }
    
    func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
        let firstItem = placemark.locality //placemark.areasOfInterest?[0] ?? placemark.locality
        let availableInfo:[String?] = [firstItem, placemark.administrativeArea, placemark.country]
        let string = availableInfo.compactMap{ $0 }.joined(separator: ", ")
        return string
    }
}

struct ResultsRow:View {
    var item:MKMapItem
    var action:(MKMapItem)->()
    
    var body: some View {
        HStack {
            //                    Image(systemName: "globe").resizable()
            //                        .aspectRatio(contentMode: .fit)
            Button(action: { action(item) },
                   label: { MapItemRow(item: item) }
            ).buttonStyle(.bordered)
                .layoutPriority(3)
        }
    }
}

struct SuggestionRow: View {
    let item:MKLocalSearchCompletion
    public var body: some View {
        VStack(alignment: .leading) {
                Text("\(item.title)")
                Text("\(item.subtitle)").font(.caption)
            }
    }
}


//public struct CompletionItemRow: View {
//    @EnvironmentObject var infoService:LocationSearchService
//    let item:MKLocalSearchCompletion
//    
//    //        Has no effect on layout issues
//    //        let charset = CharacterSet.alphanumerics.inverted
//    //            .trimmingCharacters(in: charset)
//    
//    public var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("\(item.title)")
//                Text("\(item.subtitle)").font(.caption)
//            }
//            Button("") {
//                infoService.runSuggestedItemSearch(for: item)
//            }
//        }
//    }
//}

struct LocationPickerLabelLayout:View {
    @Binding var item:MKMapItem
    
    var body: some View {
        
        HStack {
            Image(systemName: "globe")
                //.imageScale(.large)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text(item.name ?? "No name provided")
                Text(descriptionFromPlacemark(item.placemark))
            }.layoutPriority(1)
        }.padding(5)
        
    }
    
    func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
        //print("LPLabelLayout descForPlacm()\(String(describing: placemark))")
        let firstItem = placemark.locality //placemark.areasOfInterest?[0] ?? placemark.locality
        let availableInfo:[String?] = [firstItem, placemark.administrativeArea, placemark.country]
        var string = availableInfo.compactMap{ $0 }.joined(separator: ", ")
        if string.isEmpty {
            string = "\(item.placemark.coordinate.latitude), \(item.placemark.coordinate.longitude)"
        }
        return string
    }
}

struct ChooserButton:View {
    var item:MKMapItem
    var action:()->()
    var body: some View {
        Button(action: { action() }, label: {
            VStack(alignment: .leading) {
                Text(item.name ?? "No name provided")
                HStack {
                    Text("\(item.placemark.coordinate.latitude)" )
                    Text("\(item.placemark.coordinate.longitude)" )
                }
            }
        }).buttonStyle(.borderedProminent)
    }
}


struct CurrentLocationButton2: View {
    let locationRequester:()->CLLocation?
    @Binding var mapItem:MKMapItem
    
    var body: some View {
        LocationButton(.currentLocation) {
            mapItem = MKMapItem.forCurrentLocation()
        }.symbolVariant(.fill)
            .labelStyle(.iconOnly)
            .foregroundColor(Color.white)
            .cornerRadius(20)
        
    }
}



struct CurrentLocationButton: View {
    let locationRequester:()->CLLocation?
    @Binding var location:CLLocation?
    
    var body: some View {
        LocationButton(.currentLocation) {
            location = locationRequester()
        }.symbolVariant(.fill)
            .labelStyle(.iconOnly)
            .foregroundColor(Color.white)
            .cornerRadius(20)
        
    }
}


@ViewBuilder func SuggestionsPicker(_ selectedLocation:Binding<MKMapItem>, suggestions:[MKMapItem]) -> some View {
    HStack {
        Text("Suggested:")
        Spacer()
        Picker("Suggested", selection: selectedLocation) {
            ForEach(suggestions, id: \.self) { option in
                Text(option.name ?? "No description")
            }
        }
    }
}


//@ViewBuilder func SuggestionsPicker<LocationType:Locatable>(_ selectedLocation:Binding<LocationType>, suggestions:[LocationType]) -> some View {
//    Picker("Interesting", selection: selectedLocation) {
//        ForEach(suggestions, id: \.self) { option in
//            Text(option.description)
//        }
//    }
//}
