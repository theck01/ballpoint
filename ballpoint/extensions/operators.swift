//
//  operators.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/26/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//



/// Custom infix operator for boolean && assignment.
infix operator &&=: AssignmentPrecedence
infix operator ||=: AssignmentPrecedence

extension Bool {
  public static func &&= (left: inout Bool, right: Bool) {
    left = left && right
  }
  
  public static func ||= (left: inout Bool, right: Bool) {
    left = left || right
  }
}
