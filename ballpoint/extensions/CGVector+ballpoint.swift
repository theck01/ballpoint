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
  var angleInRadians: CGFloat {
    if dx == 0 {
      if dy > 0 {
        return 90
      } else if dy < 0 {
        return 270
      }

      fatalError("Cannot get the angle of a zero vector.")
    }

    if dx > 0 && dy > 0 {
      return atan(dy / dx)
    } else if dx < 0 && dy > 0 {
      return CGFloat(M_PI - Double(atan(dy / -dx)))
    } else if dx < 0 && dy < 0 {
      return CGFloat(M_PI + Double(atan(dy / dx)))
    } else {
      return CGFloat(2 * M_PI - Double(atan(-dy / dx)))
    }
  }

  var angleInDegrees: CGFloat {
    return angleInRadians * CGFloat(180 / M_PI)
  }

  var magnitude: CGFloat {
    return sqrt(pow(dx, 2) + pow(dy, 2))
  }


  /**
   - parameter vector:

   - returns: The minimum angle between the two vectors in degrees,
        counter-clockwise or clockwise.
   */
  func angleBetweenVector(vector: CGVector) -> CGFloat {
    let selfAngle = angleInDegrees
    let otherAngle = vector.angleInDegrees

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


  /**
   - parameter magnitude:

   - returns: A vector in the same direction as this vector, but with the given
        magnitude.
   */
  func vectorWithMagnitude(magnitude: CGFloat) -> CGVector {
    let selfAngle = angleInRadians
    return CGVector(
        dx: cos(selfAngle) * magnitude, dy: sin(selfAngle) * magnitude)
  }


  /**
   - parameter angleInRadians:

   - returns: A vector with the same magnitude as this vector, after having
       been rotated.
   */
  func vectorRotatedBy(angleInRadians: CGFloat) -> CGVector {
    let newAngle = angleInRadians + self.angleInRadians
    let selfMagnitude = magnitude
    return CGVector(
        dx: cos(newAngle) * selfMagnitude, dy: sin(newAngle) * magnitude)
  }
}
