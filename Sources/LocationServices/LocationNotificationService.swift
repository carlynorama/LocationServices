//
//  File.swift
//  
//
//  Created by Labtanza on 9/21/22.
//

import Foundation


struct LocationNotificationCenter {
    let notificationCenter:NotificationCenter
    let notificationName:Notification.Name
    let locationInfoKey:String
    
    func  makeLocationWatcher() -> LocationInfoWatcher
    { LocationInfoWatcher(
        name: notificationName,
        center: notificationCenter,
        keyString: locationInfoKey
    )
    }

    public func postNewLocationInfo(_ location:LSLocation, object:Any? = nil) {
        notificationCenter.post(name: notificationName, object: object ?? self, userInfo: [locationInfoKey : location])
    }
    
    public struct LocationInfoWatcher: AsyncSequence, AsyncIteratorProtocol {
        public typealias Element = LSLocation
        
        let name:Notification.Name
        let center:NotificationCenter
        let keyString:String?
        
        public init(name: Notification.Name, center: NotificationCenter, keyString:String? = nil) {
            self.name = name
            self.center = center
            self.keyString = keyString
        }
        
        private var isActive = true
        
        mutating public func next() async throws -> Element? {
            guard isActive else { return nil }
            let keyS = self.keyString
            let sequence = center.notifications(named: name).compactMap { notification in
                //note this filters out nil responses which will prevent this seqiuence from
                //terminating.
                if let keyS {
                    return notification.userInfo?[keyS] as? Element
                } else {
                    let values = notification.userInfo?.values
                    //values.first as? Element
                    if let values {
                        for value in values {
                            if let item = value as? Element {
                                return item
                            }
                        }
                    }
                }
                return nil
            }
            
            for await object in sequence {
                //print("what did I get?:\(object)")
                return object
            }
            return nil
        }
        
        public func makeAsyncIterator() -> LocationInfoWatcher {
            self
        }
    }
    
}
