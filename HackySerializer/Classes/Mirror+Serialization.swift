//
//  Mirror+Serialization.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

func cast(value: Any) throws -> AnyObject {
  guard let object = value as? AnyObject else {
    throw SerializationError.CastFailed(reason: "value \(value) could not be cast to AnyObject")
  }
  
  return object
}

extension Mirror {
  
  var serializedSubject: AnyObject {
    do {
      switch self.displayStyle {
      case .Collection?, .Set?:
        return try self.children.map { child -> AnyObject in
          let childValue = child.value
          let childValueMirror = Mirror(reflecting: childValue)
          return childValueMirror.displayStyle == nil
            ? try cast(childValue)
            : childValueMirror.serializedSubject
        }
        
      case .Struct?, .Class?:
        var dictionary: [String: AnyObject] = [:]
        for child in self.children {
          guard let key = child.label else {
            continue
          }
          
          let childMirror = Mirror(reflecting: child)
          let childValueMirror = Mirror(reflecting: child.value)
          
          switch (childMirror.displayStyle, childValueMirror.displayStyle) {
          case (.Tuple?, nil):
            if case let value? = childMirror.descendant(1) {
              dictionary[key] = try cast(value)
            } else {
              dictionary[key] = NSNull()
            }
            
          case (.Tuple?, .Optional?):
            if case let value? = childValueMirror.descendant(0) {
              let valueIsEnum = Mirror(reflecting: value).displayStyle == .Enum
              dictionary[key] = valueIsEnum ? "\(value)" : try cast(value)
            } else {
              dictionary[key] = NSNull()
            }
            
          case (.Tuple?, .Enum?):
            if case let value? = childMirror.descendant(1) {
              dictionary[key] = "\(value)"
            } else {
              dictionary[key] = NSNull()
            }
            
          default:
            dictionary[key] = childValueMirror.serializedSubject
          }
        }
        
        return dictionary
        
      case .Optional?:
        if case let value? = self.descendant(0) {
          return try cast(value)
        } else {
          return NSNull()
        }
        
      case .Dictionary?:
        var dictionary: [String: AnyObject] = [:]
        try self.children
          .map { Mirror(reflecting: $0) }
          .flatMap {
            guard let key = $0.descendant(1, 0) as? String else {
              fatalError("Only string keys are supported in dictionaries")
            }
            
            guard let value = $0.descendant(1, 1) else {
              return nil
            }
            
            let childValueMirror = Mirror(reflecting: value)
            let unwrappedValue = childValueMirror.displayStyle == nil
              ? try cast(value)
              : childValueMirror.serializedSubject
            
            return (key, unwrappedValue)
          }
          .forEach { dictionary[$0] = $1 }
        
        return dictionary
        
      default:
        fatalError("serialization failed, \(self.displayStyle) serialization is not implemented")
      }
    } catch let SerializationError.CastFailed(reason) {
      fatalError("serialization failed, \(reason)")
    } catch {
      fatalError("serialization failed")
    }
  }
}
