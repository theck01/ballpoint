//
//  PointUtil.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/31/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



public class PointUtil {
  /**
   - parameter points:

   - returns: Whether the points all exist on a line.
   */
  public static func arePointsCollinear(points: [CGPoint]) -> Bool {
    if points.count < 2 {
      return false
    }

    let firstLinePoint = points[0]
    var maybeSecondLinePoint: CGPoint? = nil
    for p in points {
      if p =~= firstLinePoint {
        continue
      }
      maybeSecondLinePoint = p
      break
    }

    // If all points within the array are equal then do nothing.
    guard let secondLinePoint = maybeSecondLinePoint else {
      return true
    }

    let pointLine = Line(point: firstLinePoint, otherPoint: secondLinePoint)
    for p in points {
      if !Line.isPoint(p, onLine: pointLine) {
        return false
      }
    }

    return true
  }


  /**
   - parameter points:

   - returns: Whether the points all exist on a line.
   */
  public static func arePointsCollinear(points: CGPoint...) -> Bool {
    return PointUtil.arePointsCollinear(points)
  }

}
