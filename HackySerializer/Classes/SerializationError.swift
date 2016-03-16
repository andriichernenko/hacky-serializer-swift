//
//  SerializationError.swift
//  HackySerializer
//
//  Created by Andrii Chernenko on 16/03/16.
//  Copyright © 2016 Andrii Chernenko. All rights reserved.
//

enum SerializationError: ErrorType {
  case CastFailed(reason: String)
}