//
//  ScaffoldSegmentFactory.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/6/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



struct ScaffoldSegmentFactory {
  /**
   - parameter origin:
   - parameter originTangentLine: The line tangent to segment at the origin.
   - parameter terminal:
   - parameter terminalTangentLine: The line tangent to segment at the terminal.

   - returns: The segment connecting the origin to the terminal.
   */
  static func generateSegment(
      origin origin: CGPoint, originTangentLine: Line, terminal: CGPoint,
      terminalTangentLine: Line) -> ScaffoldSegment {
    if let cubicSegment = maybeCreateCubicBezierSegment(
        origin: origin, originTangentLine: originTangentLine,
        terminal: terminal, terminalTangentLine: terminalTangentLine) {
      return cubicSegment
    }

    // Default to creating a linear segment if no other segment types apply to
    // the set of points.
    return LinearScaffoldSegment(origin: origin, terminal: terminal)
  }


  /**
   - parameter origin:
   - parameter originTangentLine: The line tangent to segment at the origin.
   - parameter terminal:
   - parameter terminalTangentLine: The line tangent to segment at the terminal.

   - returns: The segment connecting the origin to the terminal.
   */
  static func maybeCreateCubicBezierSegment(
      origin origin: CGPoint, originTangentLine: Line, terminal: CGPoint,
      terminalTangentLine: Line) -> CubicBezierScaffoldSegment? {
    guard let segment = LineSegment(point: origin, otherPoint: terminal)
        else { return nil }
    let segmentMidpoint = LineSegment.midpoint(segment)

    let firstControlPoint =
        Line.projectionOfPoint(segmentMidpoint, onLine: originTangentLine)
    let secondControlPoint =
        Line.projectionOfPoint(segmentMidpoint, onLine: terminalTangentLine)

    return CubicBezierScaffoldSegment(
        origin: origin, terminal: terminal,
        firstControlPoint: firstControlPoint,
        secondControlPoint: secondControlPoint)
  }
}