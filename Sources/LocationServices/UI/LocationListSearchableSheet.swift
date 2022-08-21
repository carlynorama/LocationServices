//
//  LocationSearchField.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI
import MapKit


struct LocationListSearchableSheet: View {
    //SAME AS CHOOSER SHEET
    @EnvironmentObject var searchService:LocationSearchService
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedItem:MKMapItem
    @Binding var mapitem:MKMapItem
    //END SAME
    
    //Does not care about style. 
    init(mapitem locbind:Binding<MKMapItem>) {
        self._mapitem = locbind
        self._selectedItem = State(initialValue: locbind.wrappedValue)
    }

    

    @State private var searchText = ""
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.isSearching) var isSearching



    var body: some View {
        NavigationView {
                VStack {
                    CurrentSelectedButton(item: selectedItem, action: updateLocation)
                    List(searchService.resultItems, id:\.self) { item in
                        
                        ResultsRow(item: item, action: { _ in updateSelected(item: item)})
                    }.listStyle(.plain)
                        .searchable(text: $searchText) {
                            if searchService.recentSearches.count > 0 {
                                ForEach(searchService.recentSearches, id:\.self) { item in
                                    Text(item).searchCompletion(item)
                                }
                            }
                            ForEach(searchService.suggestedItems) { suggestion in
                                SuggestionRowLabel(suggestion: suggestion)
                                    .searchCompletion(suggestion.title + " " + suggestion.subtitle)
                            }
                        }.onChange(of: searchText) { newQuery in
                            //does the search field provide the debounce?
                            //add the one bite of the aple code from custom search field?
                            searchService.fetchSuggestions(with: newQuery)
                        }.onSubmit(of: .search) {
                            searchService.runKeywordSearch(for: searchText)
                            searchService.addToRecentSearches(searchText)
                            searchService.clearSuggestions()
                            
                        }
                    
                }
            }
        }
    
    
    //SAME AS CHOOSER SHEET
    func fullUpdateAndClose(item:MKMapItem) {
        updateSelected(item: item)
        updateLocation()
    }
    
    func updateSelected(item:MKMapItem) {
        selectedItem = item
        //if searchService.resultItems.count == 1 {
            updateLocation()
        //}
    }
    
    func updateLocation() {
        mapitem = selectedItem
        searchService.clearSuggestions()
        close()
    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
    //END SAME
}

//struct LocationListSearchableView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationListSearchableView().environmentObject(LocationSearchService())
//    }
//}
