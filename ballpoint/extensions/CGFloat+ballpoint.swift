//
//  CGFloat+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/18/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics


extension CGFloat: RoughlyEquatable {
  fileprivate static let kAcceptableDiffForRoughEquality: CGFloat = 0.00001


  public func roughlyEquals<T : RoughlyEquatable>(_ otherValue: T) -> Bool {
    guard let floatValue = otherValue as? CGFloat else {
      return false
    }
    return self == floatValue ||
      fabs(self - floatValue) <= CGFloat.kAcceptableDiffForRoughEquality
  }
}
