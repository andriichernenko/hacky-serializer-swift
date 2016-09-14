//
//  Mirror+Serialization.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

private func cast(_ value: Any) -> AnyObject {
  return value as AnyObject
}


extension Mirror {
  
  var serializedSubject: AnyObject {
    switch self.displayStyle {
      
    case .collection?, .set?:
      return self.children.map { child -> AnyObject in
        let childValue = child.value
        let childValueMirror = Mirror(reflecting: childValue)
        return childValueMirror.displayStyle == nil
          ? cast(childValue)
          : childValueMirror.serializedSubject
        } as AnyObject
      
    case .struct?, .class?:
      var dictionary: [String: AnyObject] = [:]
      for child in self.children {
        guard let key = child.label else {
          continue
        }
        
        let childMirror = Mirror(reflecting: child)
        let childValueMirror = Mirror(reflecting: child.value)
        
        switch (childMirror.displayStyle, childValueMirror.displayStyle) {
        case (.tuple?, nil):
          if case let value? = childMirror.descendant(1) {
            dictionary[key] = cast(value)
          } else {
            dictionary[key] = NSNull()
          }
          
        case (.tuple?, .optional?):
          if case let value? = childValueMirror.descendant(0) {
            let valueIsEnum = Mirror(reflecting: value).displayStyle == .enum
            dictionary[key] = cast(valueIsEnum ? "\(value)" : value)
          } else {
            dictionary[key] = NSNull()
          }
          
        case (.tuple?, .enum?):
          if case let value? = childMirror.descendant(1) {
            dictionary[key] = "\(value)" as AnyObject?
          } else {
            dictionary[key] = NSNull()
          }
          
        default:
          dictionary[key] = childValueMirror.serializedSubject
        }
      }
      
      return dictionary as AnyObject
      
    case .optional?:
      if case let value? = self.descendant(0) {
        return cast(value)
      } else {
        return NSNull()
      }
      
    case .dictionary?:
      var dictionary: [String: AnyObject] = [:]
      self.children
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
            ? cast(value)
            : childValueMirror.serializedSubject
          
          return (key, unwrappedValue)
        }
        .forEach { dictionary[$0] = $1 }
      
      return dictionary as AnyObject
      
    default:
      fatalError("serialization failed, \(self.displayStyle) serialization is not implemented")
    }

  }
}
