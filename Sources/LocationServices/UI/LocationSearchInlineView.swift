//
//  LocationSearchInlineResult.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//  https://swiftwithmajid.com/2020/03/18/anchor-preferences-in-swiftui/

import SwiftUI
import MapKit

#if canImport(Layout)

public struct LocationSearchInlineView: View {
    
    @State var selectedItem:MKMapItem
    @Binding var mapitem:MKMapItem
    
    //Does not care about style.
    public init(mapitem locbind:Binding<MKMapItem>, resultCount:Int = 8, reservingSpace:Bool = false) {
        self._mapitem = locbind
        self._selectedItem = State(initialValue: locbind.wrappedValue)
        self.numberOfItems = resultCount
        self.reservingSpace = reservingSpace
    }
    
    @EnvironmentObject var searchService:LocationSearchService
    
    var promptText:String = "Search for a location"
    //@Binding var debouncedText : String
    @StateObject private var textObserver:TextFieldObserver = TextFieldObserver(delay: 0.2)
    
    @State var searchTextField = ""
    @State var shouldSuggest = true
    @State var showSuggestions = false
    
    @State var searching = false
    
    @FocusState private var searchIsFocused: Bool
    
    
    //TODO: Layout
    //Custom alignment guide that can swap it from a drop down to a pop up
    let numberOfItems:Int  //based on space? preference in init?
    let reservingSpace:Bool
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location.magnifyingglass").foregroundColor(.secondary)
                TextField(promptText, text: $textObserver.searchText)
                    .textFieldStyle(LocationSearchTextFieldStyle())
                    .focused($searchIsFocused)
                    .onReceive(textObserver.$debouncedText) { (val) in
                        searchTextField = val
                    }
                    .onSubmit() {
                        searching = true
                        searchService.runKeywordSearch(for: searchTextField)
                        searchService.addToRecentSearches(searchTextField)
                        searchService.clearSuggestions()
                    }
                    .onChange(of: $searchTextField.wrappedValue) { text in
                        searching = true
                        if shouldSuggest == true {
                            searchService.fetchSuggestions(with: searchTextField)
                        }
                        shouldSuggest = true
                        
                        if searchTextField.isEmpty {
                            withAnimation {
                                showSuggestions = false
                            }
                            searchService.clearSuggestions()
                        }
                    }
            }
            if !reservingSpace {
                if searching {
                    searchContent
                        .frame(minHeight: 200, maxHeight: 400)
                        .transition(resultReveal)
                }
            } else {
                ReserveSpaceWithFirstView(count: numberOfItems) {
                    ResultsRow(item: MKMapItem.example, action: { _ in print("Placeholder")}).opacity(0)
                    searchContent
                }//.frame(minHeight: 200, maxHeight: 400)
            }
            
        }
        .onChange(of: searchService.suggestedItems.count) { newValue in
            if newValue > 0 {
                withAnimation {
                    showSuggestions = true
                }
            } else {
                withAnimation {
                    showSuggestions = false
                }
            }
        }
    }
    
    @ViewBuilder private var suggestionsList: some View {
        VStack(alignment: .leading) {
            ForEach(searchService.suggestedItems.prefix(numberOfItems), id:\.self) { item in
                SuggestionRowButton(suggestion: item, action: chooseSuggestion)
                Divider()
            }
        }
        
    }
    
    @ViewBuilder private var searchContent: some View {
        ZStack {
            if !showSuggestions {
                ScrollView() {
                    VStack(alignment: .trailing) {
                        ForEach(searchService.resultItems, id:\.self) { item in
                            ResultsRow(item: item, action: { _ in fullUpdateAndClose(item:item)})
                        }
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
            
            if showSuggestions {
                ScrollView {
                    suggestionsList//.modifier(SuggestionsBackgroundModifier())
                }
            }
            
        }
    }
    
    func runSearch(_ suggestion:MKLocalSearchCompletion) {
        textObserver.overrideText(suggestion.id)
        searchService.clearSuggestions()
        searchService.runSuggestedItemSearch(for: suggestion)
        searchService.clearSuggestions()
    }
    
    func chooseSuggestion(item:MKLocalSearchCompletion) {
        shouldSuggest = false
        runSearch(item)
    }
    
    func fullUpdateAndClose(item:MKMapItem) {
        updateSelected(item: item)
        updateLocation()
        endSearch()
    }
    
    func updateSelected(item:MKMapItem) {
        selectedItem = item
    }
    
    func updateLocation() {
        mapitem = selectedItem
    }
    
    func endSearch() {
        searching = false
        searchService.clearSuggestions()
        searchService.clearResults()
    }
    
    
    var resultReveal:AnyTransition {
        //AnyTransition.scale(scale: 2, anchor: UnitPoint(x: 1, y: 0))
        AnyTransition.opacity.combined(with: .move(edge: .top)).combined(with: verticalClipTransition)
    }
    
    struct VerticalClipEffect:ViewModifier {
        var value: CGFloat
        
        func body(content: Content) -> some View {
            content
                .clipShape(Rectangle().scale(x: 1, y: value, anchor: .top))
        }
    }
    
    var verticalClipTransition:AnyTransition {
        .modifier(
            active: VerticalClipEffect(value: 0),
            identity: VerticalClipEffect(value: 1)
        )
    }
    
    

    
    
    enum StyleConstants {
        static let inset = 5.0
        static let menuBackgroundOpacity = 0.5
    }
    
    //    struct SuggestionsBackgroundModifier: ViewModifier {
    //
    //        func body(content: Content) -> some View {
    //            content
    //                .background(Rectangle()
    //                    .fill(Color(UIColor.systemGray6))
    //                    .opacity(StyleConstants.menuBackgroundOpacity)
    //                            //.foregroundStyle(.ultraThinMaterial)
    //                )
    //                .transition(.opacity)
    //                .padding(EdgeInsets(top: 0, leading: StyleConstants.inset, bottom: 0, trailing: StyleConstants.inset))
    //
    //
    //        }
    //    }
    
    struct LocationSearchTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<_Label>) -> some View {
            configuration
                .padding(StyleConstants.inset)
                .background(RoundedRectangle(cornerRadius: StyleConstants.inset).fill(Color(UIColor.systemGray6)))
        }
    }
}



struct ReserveSpaceWithFirstView:Layout {
    
    //needs a sizeThatFits
    let count:Int
    let widthComfort = 1.3
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizeLimiter = subviews[0].sizeThatFits(.unspecified)
        let suggestedSize = proposal.replacingUnspecifiedDimensions()
        let size = CGSize(width: max(sizeLimiter.width * widthComfort, suggestedSize.width).rounded(), height: max(sizeLimiter.height * CGFloat(count), suggestedSize.height))
        return size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 2 else {
            print("This a container for 1 right now.")
            fatalError("This a container for 1 right now.")
        }
        
        
//        subviews[0].place(
//            at: CGPoint(x: -1000, y: -1000),
//            proposal: proposal
//        )
        
        subviews[1].place(
            at: bounds.origin,
            proposal: proposal
        )
        
        
    }
    
    
}



//struct LocationSearchInlineView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationSearchInlineView(resultCount: 5).environmentObject(LocationSearchService())
//    }
//}
#endif
