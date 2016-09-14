//
//  HackySerializable.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

public protocol HackySerializable {
  
  var serialized: AnyObject { get }
}

public extension HackySerializable {
  
  var serialized: AnyObject {
    return Mirror(reflecting: self).serializedSubject
  }
}
