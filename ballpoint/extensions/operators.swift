//
//  operators.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/26/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//



/// Custom infix operator for boolean && assignment.
infix operator &&= { associativity right precedence 90 }
public func &&= (inout left: Bool, right: Bool) {
  left = left && right
}


/// Custom infix operator for boolean || assignment.
infix operator ||= { associativity right precedence 90 }
public func ||= (inout left: Bool, right: Bool) {
  left = left || right
}


/// Custom infix operator for optional initialization assignment.
infix operator ??= { associativity right precedence 90 }
public func ??= <T> (inout left: T?, right: T) {
  left = left ?? right
}