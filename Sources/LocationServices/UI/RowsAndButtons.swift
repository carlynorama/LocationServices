//
//  RowViews.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI
import MapKit

#if canImport(CoreLocationUI)
import CoreLocationUI
#endif

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
//        HStack {
//                                Image(systemName: "globe").resizable()
//                                    .aspectRatio(contentMode: .fit)
            Button(action: { action(item) },
                   label: { MapItemRow(item: item) }
            ).buttonStyle(.bordered)
                .layoutPriority(3)
        }
  //  }
}

struct DefaultLabelTextStack:View {
    let title:String
    let description:String
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("\(title)")
                .multilineTextAlignment(.leading)
                .allowsTightening(true)
                Text("\(description)")
                .font(.caption)
                .multilineTextAlignment(.leading)
                .allowsTightening(true)
            }
    }
}

struct SuggestionRowLabel: View {
    let suggestion:MKLocalSearchCompletion
    public var body: some View {
        DefaultLabelTextStack(title: suggestion.title, description: suggestion.subtitle)
    }
}

struct SuggestionRowButton:View {
    let suggestion:MKLocalSearchCompletion
    let action:(MKLocalSearchCompletion)->()
    public var body: some View {
        Button(action: {
            action(suggestion)
        }, label: {
            SuggestionRowLabel(suggestion: suggestion)
        })
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
                .imageScale(.large)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
            DefaultLabelTextStack(
                title: (item.name ?? "No name provided"),
                description: (descriptionFromPlacemark(item.placemark))
            ).layoutPriority(1)
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

struct CurrentSelectedButton:View {
    var item:MKMapItem
    var action:()->()
    var body: some View {
        Button(action: { action() }, label: {
            DefaultLabelTextStack(
                title: (item.name ?? "No name provided"),
                description: "\(item.placemark.coordinate.latitude)" + " " + "\(item.placemark.coordinate.longitude)"
            )
        }).buttonStyle(.borderedProminent)
    }
}

#if canImport(CoreLocationUI)
struct CurrentLocationButton2: View {
    let locationRequester:()->CLLocation?
    @Binding var item:MKMapItem
    
    var body: some View {
        LocationButton(.currentLocation) {
            item = MKMapItem.forCurrentLocation()
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
#endif

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
