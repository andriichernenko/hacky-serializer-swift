//
//  HackySerializable.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//


public protocol HackySerializable {
  
  var serialized: Any { get }
}


public extension HackySerializable {
  
  var serialized: Any {
    return Mirror(reflecting: self).serializedSubject
  }
}
