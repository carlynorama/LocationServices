//
//  LocationPicker.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/19/22.
//



import SwiftUI
import MapKit

//https://www.swiftbysundell.com/articles/configuring-swiftui-views/
//https://stackoverflow.com/questions/57411656/difference-between-creating-viewmodifier-and-view-extension-in-swiftui
//https://medium.com/@aainajain/equatable-for-enum-with-associated-value-e07d9ab20e8e

public enum LocationPickerStyle:Equatable {
    case deviceLocation(locationRequest:()->CLLocation?)
    case popoverSearch
    case inlineSearch
    case popoverSearchWithSuggestions(items:[MKMapItem])
    case inlineSuggestions(items:[MKMapItem])
    //case inlineSuggestions(locations:[Location])
    
    public static func == (lhs: LocationPickerStyle, rhs: LocationPickerStyle) -> Bool {
        switch (lhs, rhs) {
        case (popoverSearch, popoverSearch):
            return true
        case (deviceLocation, deviceLocation):
            return true
        case (popoverSearchWithSuggestions, popoverSearchWithSuggestions):
            return true
        case (inlineSuggestions, inlineSuggestions):
            return true
        case (inlineSearch, inlineSearch):
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
    //@State private var showingSheet = false
    @State private var deviceLocation:CLLocation?
    
    public var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Choose a location")
                
                switch style {
                case .deviceLocation(let requester):
                    HStack {
                        openSearchButton
                        #if canImport(CoreLocationUI)
                        CurrentLocationButton2(locationRequester: requester, item: $item)
                        #endif
                        
                    }.popover(isPresented: $showingPopover) {
                        LocationPickerChooserContent(mapitem: $item, style:style).environmentObject(searchService)
                    }
                case .inlineSuggestions(let items):
                    SuggestionsPicker($item, suggestions: items).environmentObject(searchService)
                case .inlineSearch:
                    #if canImport(Layout)
                    LocationSearchInlineView(mapitem: $item).environmentObject(searchService)
                    #endif
                case .popoverSearch:
                    openSearchButton.popover(isPresented: $showingPopover) {
                        //LocationSearchInlineView(mapitem: $item, reservingSpace: true).environmentObject(searchService).padding()
                        LocationPickerChooserContent(mapitem: $item, style:style).environmentObject(searchService)
                    }
                default:
                    openSearchButton.sheet(isPresented: $showingPopover) {
                        LocationListSearchableSheet(mapitem: $item).environmentObject(searchService)
                        //LocationPickerChooserContent(location: $item, style:style).environmentObject(searchService)
                    }
                }
            }
            Spacer()
        }
        
        
    }
    @ViewBuilder var openSearchButton:some View {
        Button(
            action: { showingPopover.toggle() },
            label: {
                LocationPickerLabelLayout(item: $item)
            }).buttonStyle(.bordered).foregroundColor(.secondary)
    }

}









//struct LocationPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationPicker()
//    }
//}

