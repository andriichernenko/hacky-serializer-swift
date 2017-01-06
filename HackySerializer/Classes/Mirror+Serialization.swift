//
//  Mirror+Serialization.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//


fileprivate func serialize(_ value: Any) -> Any {
  return (value as? HackySerializable)?.serialized ?? Mirror(reflecting: value).serializedSubject
}


extension Mirror {
  
  var serializedSubject: Any {
    switch self.displayStyle {
      
    case .collection?, .set?:
      return children
        .map { Mirror(reflecting: $0.value).displayStyle == nil ? $0.value : serialize($0.value) }
      
    case .struct?, .class?:
      var dictionary: [String: Any] = [:]
      
      children.forEach { child in
        guard let key = child.label else { return }
        
        let childMirror = Mirror(reflecting: child)
        let childValueMirror = Mirror(reflecting: child.value)
        
        switch (childMirror.displayStyle, childValueMirror.displayStyle) {
          case (.tuple?, nil):
            dictionary[key] = childMirror.descendant(1) ?? NSNull()
            
          case (.tuple?, .optional?):
            dictionary[key] = childValueMirror.descendant(0)
              .map { Mirror(reflecting: $0).displayStyle == .enum ? "\($0)" : $0 }
              ?? NSNull()
            
          case (.tuple?, .enum?):
            dictionary[key] = childMirror.descendant(1).map { "\($0)" as Any } ?? NSNull()
            
          default:
            dictionary[key] = serialize(value: child.value)
        }
      }
      
      return dictionary

    case .optional?:
      return self.descendant(0) ?? NSNull()
      
    case .dictionary?:
      var dictionary: [String: Any] = [:]
      children
        .map { Mirror(reflecting: $0) }
        .flatMap {
          guard let key = $0.descendant(1, 0) as? String else {
            fatalError("Only string keys are supported in dictionaries")
          }
          
          guard let value = $0.descendant(1, 1) else {
            return nil
          }
          
          let childValueMirror = Mirror(reflecting: value)
          let unwrappedValue = childValueMirror.displayStyle == nil ? value : serialize(value: value)
          
          return (key, unwrappedValue)
        }
        .forEach { dictionary[$0] = $1 }
      
      return dictionary
      
    default:
      fatalError("serialization failed, \(displayStyle) serialization is not implemented")
    }
  }
}
