//
//  NSJSONSerializable.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

import Foundation

public protocol NSJSONSerializable: HackySerializable {
  
  func serializedJSONData(options: JSONSerialization.WritingOptions) throws -> Data
}

public extension NSJSONSerializable {
  
  func serializedJSONData(options: JSONSerialization.WritingOptions = []) throws -> Data {
    let serializedObject: AnyObject
    if let JSONValue = self as? JSONValue {
      serializedObject = JSONValue.JSONValue
    } else {
      serializedObject = self.serialized
    }
    
    let validatedSerializedObject = validate(serializedObject)
    
    return try JSONSerialization.data(withJSONObject: validatedSerializedObject, options: options)
  }
}

internal func validate(_ object: AnyObject) -> AnyObject {  
  switch object {
  case let value as JSONValue:
    return value.JSONValue
    
  case let dictionary as [String: AnyObject]:
    let validatedEntries = dictionary.map { key, value in (key, validate(value)) }
    
    var validatedDictionary: [String: AnyObject] = [:]
    validatedEntries.forEach{ key, value in validatedDictionary[key] = value }
    
    return validatedDictionary as AnyObject
    
  case let array as [AnyObject]:
    return array.map(validate) as AnyObject
   
  case _ as NSString, _ as NSNumber, _ as NSNull:
    return object
    
  default:
    fatalError("failed to validate '\(object)' of type '\(type(of: object))'. NSJSONSerialization supports only NSString, NSNumber, NSArray, NSDictionary, and NSNull.")
  }
}
