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
    var isPointWithinSegmentBounds = true
    isPointWithinSegmentBounds &&=
        point.x > CGRectGetMinX(segment.boundingBox) ||
        point.x =~= CGRectGetMinX(segment.boundingBox)
    isPointWithinSegmentBounds &&=
        point.x < CGRectGetMaxX(segment.boundingBox) ||
        point.x =~= CGRectGetMaxX(segment.boundingBox)
    isPointWithinSegmentBounds &&=
        point.y > CGRectGetMinY(segment.boundingBox) ||
        point.y =~= CGRectGetMinY(segment.boundingBox)
    isPointWithinSegmentBounds &&=
        point.y < CGRectGetMaxY(segment.boundingBox) ||
        point.y =~= CGRectGetMaxY(segment.boundingBox)
    return
        isPointWithinSegmentBounds && Line.isPoint(point, onLine: segment.line)
  }
}