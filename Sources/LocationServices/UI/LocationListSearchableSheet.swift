//
//  LocationSearchField.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI
import MapKit


struct LocationListSearchableSheet: View {
    @EnvironmentObject var searchService:LocationSearchService
    @State private var searchText = ""
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.isSearching) var isSearching
    @Environment(\.presentationMode) var presentationMode
    
    //@State var selectedLocation:MKMapItem
    @Binding var location:MKMapItem


    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    List(searchService.resultItems, id:\.self) { item in
                        HStack {
                            //                    Image(systemName: "globe").resizable()
                            //                        .aspectRatio(contentMode: .fit)
                            Button(action: {
                                updateSelected(item: item)
                                //updateLocation()
                            },
                                   label: { MapItemRow(item: item) }
                            ).buttonStyle(.bordered)
                                .layoutPriority(3)
                        }
                    }.listStyle(.plain)
                        .searchable(text: $searchText) {
                            if searchService.recentSearches.count > 0 {
                                ForEach(searchService.recentSearches, id:\.self) { item in
                                    Text(item).searchCompletion(item)
                                }
                            }
                            ForEach(searchService.suggestedItems) { suggestion in
                                let displayName = suggestion.title
                                Text(displayName)
                                    .searchCompletion(suggestion.title + " " + suggestion.subtitle)
                            }
                        }.onChange(of: searchText) { newQuery in
                            //does the search field provide teh debounce?
                            searchService.fetchSuggestions(with: newQuery)
                        }.onSubmit(of: .search) {
                            searchService.runKeywordSearch(for: searchText)
                            searchService.addToRecentSearches(searchText)
                            searchService.clearSuggestions()
                            
                        }
                    
                }
            }
        }
    }
    func updateSelected(item:MKMapItem) {
        location = item
    }
}

//struct LocationListSearchableView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationListSearchableView().environmentObject(LocationSearchService())
//    }
//}
