//
//  NSJSONSerializable.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

import Foundation

public protocol NSJSONSerializable: HackySerializable {
  
  func serializedJSONData(options: NSJSONWritingOptions) throws -> NSData
}

public extension NSJSONSerializable {
  
  func serializedJSONData(options: NSJSONWritingOptions = []) throws -> NSData {
    let serializedObject: AnyObject
    if let JSONValue = self as? NSJSONValue {
      serializedObject = JSONValue.NSJSONValue
    } else {
      serializedObject = self.serialized
    }
    
    let validatedSerializedObject = validate(serializedObject)
    
    return try NSJSONSerialization.dataWithJSONObject(validatedSerializedObject, options: options)
  }
}

internal func validate(object: AnyObject) -> AnyObject {  
  switch object {
  case let value as NSJSONValue:
    return value.NSJSONValue
    
  case let dictionary as [String: AnyObject]:
    let validatedEntries = dictionary.map { key, value in (key, validate(value)) }
    
    var validatedDictionary: [String: AnyObject] = [:]
    validatedEntries.forEach{ key, value in validatedDictionary[key] = value }
    
    return validatedDictionary
    
  case let array as [AnyObject]:
    return array.map(validate)
   
  case _ as NSString, _ as NSNumber, _ as NSNull:
    return object
    
  default:
    fatalError("failed to validate '\(object)' of type '\(object.dynamicType)'. NSJSONSerialization supports only NSString, NSNumber, NSArray, NSDictionary, and NSNull.")
  }
}