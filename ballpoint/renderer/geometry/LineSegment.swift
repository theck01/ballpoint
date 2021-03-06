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
  fileprivate let boundingBox: CGRect


  public init?(point: CGPoint, otherPoint: CGPoint) {
    let maybeLine = Line(point: point, otherPoint: otherPoint)
    if maybeLine == nil {
      return nil
    }
    line = maybeLine!
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
      _ point: CGPoint, onLineSegment segment: LineSegment) -> Bool {
    var isPointWithinSegmentBounds = true
    isPointWithinSegmentBounds &&=
        point.x > segment.boundingBox.minX ||
        point.x =~= segment.boundingBox.minX
    isPointWithinSegmentBounds &&=
        point.x < segment.boundingBox.maxX ||
        point.x =~= segment.boundingBox.maxX
    isPointWithinSegmentBounds &&=
        point.y > segment.boundingBox.minY ||
        point.y =~= segment.boundingBox.minY
    isPointWithinSegmentBounds &&=
        point.y < segment.boundingBox.maxY ||
        point.y =~= segment.boundingBox.maxY
    return
        isPointWithinSegmentBounds && Line.isPoint(point, onLine: segment.line)
  }


  /**
   - parameter a:
   - parameter b:

   - returns: The intersection of line segments a and b, or nil if no
        intersection exists.
   */
  public static func intersection(
      _ a: LineSegment, _ b: LineSegment) -> CGPoint? {
    if let lineIntersection = Line.intersection(a.line, b.line) {
      if LineSegment.isPoint(lineIntersection, onLineSegment: a) &&
          LineSegment.isPoint(lineIntersection, onLineSegment: b) {
        return lineIntersection
      }
    }
    return nil
  }


  /**
   - parameter segment:

   - returns: The midpoint of the line segment.
   */
  public static func midpoint(_ segment: LineSegment) -> CGPoint {
    return CGPoint(
        x: (segment.endPoints.0.x + segment.endPoints.1.x) / 2,
        y: (segment.endPoints.0.y + segment.endPoints.1.y) / 2)
  }
}
