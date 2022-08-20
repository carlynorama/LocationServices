//
//  File.swift
//  
//
//  Created by Labtanza on 8/20/22.
//

import Foundation

class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
        
    init(delay: DispatchQueue.SchedulerTimeType.Stride) {
        $searchText
            .debounce(for: delay, scheduler: DispatchQueue.main)
            .assign(to: &$debouncedText)
            //replaced this with the assign.
            //.sink(receiveValue: { [weak self] value in
            //    self?.debouncedText = value
            //})
            //.store(in: &cancellables) //-> private var cancellables = Set<AnyCancellable>()
    }
    
    public func overrideText(_ string:String) {
        searchText = string
    }
}
