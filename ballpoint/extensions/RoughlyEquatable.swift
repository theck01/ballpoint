//
//  File.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/19/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//




/// Custom infix operator for rough equality.
infix operator =~=: ComparisonPrecedence

/// Protocol for a type where exact equivalence is less important than
/// approximate equivalence.
public protocol RoughlyEquatable {
  /**
  - parameter otherValue:
  - parameter diff: Optional difference allowed between the floats to be
      considered equal. If not provided then default constant is used.

  - returns: Whether the points are within a given difference from each other.
  */
  func roughlyEquals<T: RoughlyEquatable>(_ otherValue: T) -> Bool
}

  
public func =~= <T: RoughlyEquatable> (left: T, right: T) -> Bool {
  return left.roughlyEquals(right)
}
