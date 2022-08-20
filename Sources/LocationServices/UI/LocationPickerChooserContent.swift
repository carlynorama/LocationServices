//
//  File 2.swift
//  
//
//  Created by Labtanza on 8/20/22.
//
import SwiftUI
import MapKit

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
                ChooserButton(item: selectedLocation, action: updateLocation)
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
                ResultsRow(item: item, action: { _ in fullUpdateAndClose(item: item) })
            }.listStyle(.plain)
        }.environmentObject(searchService)
            .padding(15)

    }
    
    func fullUpdateAndClose(item:MKMapItem) {
        updateSelected(item: item)
        updateLocation()
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
