//
//  LocationPicker.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/19/22.
//

import SwiftUI
import MapKit
import CoreLocationUI
//https://www.swiftbysundell.com/articles/configuring-swiftui-views/
//https://stackoverflow.com/questions/57411656/difference-between-creating-viewmodifier-and-view-extension-in-swiftui
//https://medium.com/@aainajain/equatable-for-enum-with-associated-value-e07d9ab20e8e

public enum LocationPickerStyle:Equatable {
    case deviceLocation(locationRequest:()->CLLocation?)
    case popoverSearch
    case popoverSearchWithSuggestions(items:[MKMapItem])
    case inlineSuggestions(items:[MKMapItem])
    
    public static func == (lhs: LocationPickerStyle, rhs: LocationPickerStyle) -> Bool {
        switch (lhs, rhs) {
        case (popoverSearch, popoverSearch):
            return true
        case (deviceLocation, deviceLocation):
            return true
        case (popoverSearchWithSuggestions, popoverSearchWithSuggestions):
            return true
        case (inlineSuggestions,inlineSuggestions):
            return true
        default:
            return false
        }
    }
}

extension View where Self == LocationPicker {
    public func locationPickerStyle(_ style:LocationPickerStyle) -> LocationPicker  {
        LocationPicker(item:self.$item, style: style)
    }
}


public struct LocationPicker: View {
    @StateObject var searchService:LocationSearchService = LocationSearchService()
    
    //If the style is DeviceLocation...
    public init(mapitem:Binding<MKMapItem>) {
        self._item = mapitem
        self.style = .popoverSearch
    }
    
    fileprivate init(item:Binding<MKMapItem>, style:LocationPickerStyle) {
        self._item = item
        self.style = style
    }
    
    @Binding var item:MKMapItem
    let style:LocationPickerStyle
    
    @State private var showingPopover = false
    @State private var deviceLocation:CLLocation?
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a location")
            
            switch style {
            case .deviceLocation(let requester):
                HStack {
                    openSearchButton
                    CurrentLocationButton2(locationRequester: requester, mapItem: $item)
                    
                }.popover(isPresented: $showingPopover) {
                    LocationPickerChooserContent(location: $item, style:style).environmentObject(searchService)
                }
            case .inlineSuggestions(let items):
                SuggestionsPicker($item, suggestions: items)
            default:
                openSearchButton.popover(isPresented: $showingPopover) {
                    LocationPickerChooserContent(location: $item, style:style).environmentObject(searchService)
                }
            }
        }
        
        
    }
    @ViewBuilder var openSearchButton:some View {
        Button(
            action: { showingPopover.toggle() },
            label: {
                LocationPickerLabelLayout(item: $item)
            }).buttonStyle(.bordered).foregroundColor(.secondary)
    }
    
//     mutating func locationPickerStyle(_ style:LocationPickerStyle) {
//        self.style = style
//    }

}

struct LocationPickerLabelLayout:View {
    @Binding var item:MKMapItem
    
    var body: some View {
        
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
            //                            .resizable()
            //                            .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text(item.name ?? "No name provided")
                Text(descriptionFromPlacemark(item.placemark))
//                HStack {
//                    Text("\(item.placemark.coordinate.latitude)" )
//                    Text("\(item.placemark.coordinate.longitude)" )
//                }
            }.layoutPriority(1)
        }.padding(5)

    }
    
    func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
        print("LPLabelLayout descForPlacm()\(String(describing: placemark))")
        let firstItem = placemark.locality //placemark.areasOfInterest?[0] ?? placemark.locality
        let availableInfo:[String?] = [firstItem, placemark.administrativeArea, placemark.country]
        var string = availableInfo.compactMap{ $0 }.joined(separator: ", ")
        if string.isEmpty {
            string = "\(item.placemark.coordinate.latitude), \(item.placemark.coordinate.longitude)"
        }
        return string
    }
}



struct LocationPickerChooserContent:View {
    @EnvironmentObject var searchService:LocationSearchService
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedLocation:MKMapItem
    @Binding var location:MKMapItem
    
    var style:LocationPickerStyle
    
    init(location locbind:Binding<MKMapItem>, style:LocationPickerStyle) {
        self._location = locbind
        self._selectedLocation = State(initialValue: locbind.wrappedValue)
        self.style = style
    }
    
    var body:some View {
        
        VStack(alignment:.leading, spacing: 10.0) {
            //The "Toolbar"
            HStack {
                //Button("Update") { updateLocation() }
                Spacer()
                Button("Cancel") { close() }
            }
            Text("Pick a Location").font(.title)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Location:")
                Spacer()
                Button(action: { updateLocation() }, label: {
                    VStack(alignment: .leading) {
                        Text(selectedLocation.name ?? "No name provided")
                        HStack {
                            Text("\(selectedLocation.placemark.coordinate.latitude)" )
                            Text("\(selectedLocation.placemark.coordinate.longitude)" )
                        }
                    }
                }).buttonStyle(.borderedProminent)
            }
            switch style {
            case .popoverSearchWithSuggestions(let suggestions):
                SuggestionsPicker($selectedLocation, suggestions: suggestions)
            default:
                EmptyView()
            }
            HStack {
                LocationSearchField()
                
            }.zIndex(10)
            //List(1..<5) { _ in
            List(searchService.resultItems, id:\.self) { item in
                HStack {
//                    Image(systemName: "globe").resizable()
//                        .aspectRatio(contentMode: .fit)
                    Button(action: {
                        updateSelected(item: item)
                        updateLocation()
                    },
                           label: { MapItemRow(item: item) }
                    ).buttonStyle(.bordered)
                        .layoutPriority(3)
                }
            }.listStyle(.plain)
        }.environmentObject(searchService)
            .padding(15)

    }
    
    func updateSelected(item:MKMapItem) {
        selectedLocation = item
    }
    
    func updateLocation() {
        location = selectedLocation
        close()
    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
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

@ViewBuilder func SuggestionsPicker<LocationType:Locatable>(_ selectedLocation:Binding<LocationType>, suggestions:[LocationType]) -> some View {
    Picker("Interesting", selection: selectedLocation) {
        ForEach(suggestions, id: \.self) { option in
            Text(option.description)
        }
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




//struct LocationPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationPicker()
//    }
//}
