//
//  CGFloat+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/18/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



extension CGFloat {
  private static let kAcceptableDiffForRoughEquality: CGFloat = 0.00001


  /**
  - parameter otherValue:
  - parameter diff: Optional difference allowed between the floats to be
      considered equal. If not provided then default constant is used.

  - returns: Whether the points are within a given difference from each other.
  */
  func roughlyEquals(
      otherValue: CGFloat, withinDifference diff: CGFloat? = nil) -> Bool {
    let maxDiff = diff ?? CGFloat.kAcceptableDiffForRoughEquality
    return fabs(self - otherValue) <= maxDiff
  }
}
