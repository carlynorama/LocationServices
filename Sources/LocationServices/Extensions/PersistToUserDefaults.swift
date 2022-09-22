//
//  File.swift
//  
//
//  Created by Labtanza on 9/22/22.
//

import Foundation


extension UserDefaults {
    func setCustom<Object>(_ object:Object, forKey key:String) throws where Object:Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: key)
        }catch {
            throw DefaultSavingError.unableToEncode
        }
    }
    
    func setCustomArray<Object>(_ objects:[Object], forKey key:String) throws where Object:Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(objects)
            set(data, forKey: key)
        }catch {
            throw DefaultSavingError.unableToEncode
        }
    }
    
    func getCustom<Object>(forKey key: String, as type: Object.Type) throws -> Object where Object : Decodable {
        guard let data = data(forKey: key) else { throw
            DefaultSavingError.noValue
        }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw DefaultSavingError.unableToDecode
        }
    }
    

}

enum DefaultSavingError:String, LocalizedError {
    case unableToEncode = "Unable to encode object"
    case noValue = "No data for key"
    case unableToDecode = "Unable to decode as desired type"
    
    var errorDescription: String? {
        rawValue
    }
}
