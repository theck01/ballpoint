//
//  CGVector+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



extension CGVector {
  /// The angle of the vector in degrees, clockwise from the x axis.
  var angle: CGFloat {
    if dx == 0 {
      if dy > 0 {
        return 90
      } else if dy < 0 {
        return 270
      }

      fatalError("Cannot get the angle of a zero vector.")
    }

    var angleInRadians: Double
    if dx > 0 && dy > 0 {
      angleInRadians = Double(atan(dy / dx))
    } else if dx < 0 && dy > 0 {
      angleInRadians = M_PI - Double(atan(dy / -dx))
    } else if dx < 0 && dy < 0 {
      angleInRadians = M_PI + Double(atan(dy / dx))
    } else {
      angleInRadians = 2 * M_PI - Double(atan(-dy / dx))
    }

    return CGFloat(angleInRadians * (180 / M_PI))
  }


  /**
   - parameter vector:

   - returns: The minimum angle between the two vectors in degrees,
        counter-clockwise or clockwise.
   */
  func angleBetweenVector(vector: CGVector) -> CGFloat {
    let selfAngle = angle
    let otherAngle = vector.angle

    if selfAngle < otherAngle {
      return otherAngle - selfAngle < 180 ?
          otherAngle - selfAngle :
          selfAngle + (360 - otherAngle)
    } else {
      return selfAngle - otherAngle < 180 ?
          selfAngle - otherAngle :
          otherAngle + (360 - selfAngle)
    }
  }
}
