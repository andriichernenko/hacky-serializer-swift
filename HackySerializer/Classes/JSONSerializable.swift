//
//  NSJSONSerializable.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

import Foundation

public protocol JSONSerializable: HackySerializable {
  
  func serializedJSONData(options: JSONSerialization.WritingOptions) throws -> Data
}

public extension JSONSerializable {
  
  func serializedJSONData(options: JSONSerialization.WritingOptions = []) throws -> Data {
    let validatedSerializedObject = validate(self.serialized)
    return try JSONSerialization.data(withJSONObject: validatedSerializedObject, options: options)
  }
}

internal func validate(_ object: Any) -> Any {
  switch object {
  case let value as HackySerializable:
    return value.serialized
    
  case let dictionary as [String: Any]:
    let validatedEntries = dictionary.map { key, value in (key, validate(value)) }
    
    var validatedDictionary: [String: Any] = [:]
    validatedEntries.forEach{ key, value in validatedDictionary[key] = value }
    
    return validatedDictionary
    
  case let array as [AnyObject]:
    return array.map(validate)
   
  case _ as NSString, _ as NSNumber, _ as NSNull:
    return object
    
  default:
    fatalError("failed to validate '\(object)' of type '\(type(of: object))'. NSJSONSerialization supports only NSString, NSNumber, NSArray, NSDictionary, and NSNull.")
  }
}
