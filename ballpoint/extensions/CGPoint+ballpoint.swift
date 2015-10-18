//
//  CGPoint+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/18/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



public extension CGPoint {
  /**
  - parameter otherPoint:
  - parameter diff: Optional difference allowed between the floats to be
      considered equal. If not provided then default constant is used.

  - returns: Whether the points are within a given difference from each other.
  */
  public func roughlyEquals(
      otherPoint: CGPoint, withinDifference diff: CGFloat? = nil) -> Bool {
    return
        self.x.roughlyEquals(otherPoint.x, withinDifference: diff) &&
        self.y.roughlyEquals(otherPoint.y, withinDifference: diff)
  }
}
