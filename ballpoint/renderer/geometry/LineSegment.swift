//
//  LineSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/25/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



public struct LineSegment {
  let line: Line
  let endPoints: (CGPoint, CGPoint)
  private let boundingBox: CGRect


  public init(point: CGPoint, otherPoint: CGPoint) {
    line = Line(point: point, otherPoint: otherPoint)
    endPoints = (point, otherPoint)
    boundingBox = CGRect(
        x: fmin(point.x, otherPoint.y), y: fmin(point.y, otherPoint.y),
        width: fmax(point.x, otherPoint.x), height: fmax(point.y, otherPoint.y))
  }
}



public extension LineSegment {
  /**
   - parameter point:
   - parameter segment:

   - returns: Whether the point is on the line segment.
   */
  public static func isPoint(
      point: CGPoint, onLineSegment segment: LineSegment) -> Bool {
    return
        CGRectContainsPoint(segment.boundingBox, point) &&
        Line.isPoint(point, onLine: segment.line)
  }
}