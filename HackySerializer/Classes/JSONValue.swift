//
//  JSONValue.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

import Foundation

public protocol JSONValue {
  
  var JSONValue: AnyObject { get }
}

public extension JSONValue {
  
  var JSONValue: AnyObject {
    return "\(self)" as AnyObject
  }
}
