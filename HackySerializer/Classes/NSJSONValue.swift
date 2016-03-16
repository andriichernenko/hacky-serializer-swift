//
//  NSJSONValue.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

import Foundation

public protocol NSJSONValue {
  
  var NSJSONValue: AnyObject { get }
}

public extension NSJSONValue {
  
  var NSJSONValue: AnyObject {
    return "\(self)"
  }
}