//
//  CGFloat+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/18/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics


extension CGFloat: RoughlyEquatable {
  private static let kAcceptableDiffForRoughEquality: CGFloat = 0.00001


  public func roughlyEquals<T : RoughlyEquatable>(otherValue: T) -> Bool {
    guard let floatValue = otherValue as? CGFloat else {
      return false
    }
    return fabs(self - floatValue) <= CGFloat.kAcceptableDiffForRoughEquality
  }
}
