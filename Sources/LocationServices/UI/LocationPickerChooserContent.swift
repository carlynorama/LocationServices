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
    
    @State var selectedItem:MKMapItem
    @Binding var mapitem:MKMapItem
    
    var style:LocationPickerStyle
    
    var numberOfItems = 8
    
    init(mapitem locbind:Binding<MKMapItem>, style:LocationPickerStyle) {
        self._mapitem = locbind
        self._selectedItem = State(initialValue: locbind.wrappedValue)
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
                CurrentSelectedButton(item: selectedItem, action: updateLocation)
            }
            switch style {
            case .popoverSearchWithSuggestions(let suggestions):
                SuggestionsPicker($selectedItem, suggestions: suggestions)
            default:
                EmptyView()
            }
            HStack {
                LocationSearchField()
                
            }.zIndex(10)
            //List(1..<5) { _ in
            
            ReserveSpaceWithFirstView(count: numberOfItems) {
                VStack() {
                    Text("The Long Place Name, CA, Independent Sov")
                    Text("Line 1")
                    Text("Line 1")  }
                //ResultsRow(item: MKMapItem.example, action: { _ in print("Placeholder")}).opacity(0)
                //searchContent

                List(searchService.resultItems, id:\.self) { item in
                    ResultsRow(item: item, action: { _ in fullUpdateAndClose(item: item) })
                }.listStyle(.plain)
            }
            
        }.environmentObject(searchService)
            .padding(15)

    }
    
    func fullUpdateAndClose(item:MKMapItem) {
        updateSelected(item: item)
        updateLocation()
    }
    
    func updateSelected(item:MKMapItem) {
        selectedItem = item
    }
    
    func updateLocation() {
        mapitem = selectedItem
        close()
    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
    
}
