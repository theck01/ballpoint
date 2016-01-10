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
   - parameter previousPoint: The point preceeding the origin of the segment to
       be created, or nil if one does not exist. Used to apply the appropriate
       curve to the segment
   - parameter origin:
   - parameter terminal:
   - parameter nextPoint: The point following the terminal of the segment to be
       created, or nil if one does not exist. Used to apply the appropriate
       curve to the segment
   
   - returns: The segment connecting the origin to the terminal.
   */
  static func generateSegment(
      previousPoint previousPoint: CGPoint?, origin: CGPoint, terminal: CGPoint,
      nextPoint: CGPoint?) -> ScaffoldSegment {
    if let cubicSegment = maybeCreateCubicBezierSegment(
        previousPoint: previousPoint, origin: origin, terminal: terminal,
        nextPoint: nextPoint) {
      return cubicSegment
    }

    // Default to creating a linear segment if no other segment types apply to
    // the set of points.
    return LinearScaffoldSegment(origin: origin, terminal: terminal)
  }


  /**
   - parameter previousPoint: The point preceeding the origin of the segment to
       be created, or nil if one does not exist. Used to apply the appropriate
       curve to the segment
   - parameter origin:
   - parameter terminal:
   - parameter nextPoint: The point following the terminal of the segment to be
       created, or nil if one does not exist. Used to apply the appropriate
       curve to the segment
   
   - returns: The CubicBezierScaffoldSegment connecting the origin to the
       terminal, or nil if a cubic bezier is not the appropriate connector for
       the origin and terminal.
   */
  static func maybeCreateCubicBezierSegment(
      previousPoint previousPoint: CGPoint?, origin: CGPoint, terminal: CGPoint,
      nextPoint: CGPoint?) -> CubicBezierScaffoldSegment? {
    guard let segment = LineSegment(point: origin, otherPoint: terminal)
        else { return nil }
    let segmentMidpoint = LineSegment.midpoint(segment)

    let originTangentSlopeLine = previousPoint != nil ?
        Line(point: previousPoint!, otherPoint: terminal) ?? segment.line :
        segment.line
    let originTangentLine =
        Line(slope: originTangentSlopeLine.slope, throughPoint: origin)
    let firstControlPoint =
        Line.projectionOfPoint(segmentMidpoint, onLine: originTangentLine)

    let terminalTangentSlopLine = nextPoint != nil ?
        Line(point: origin, otherPoint: nextPoint!) ?? segment.line :
        segment.line
    let terminalTangentLine =
        Line(slope: terminalTangentSlopLine.slope, throughPoint: terminal)
    let secondControlPoint =
        Line.projectionOfPoint(segmentMidpoint, onLine: terminalTangentLine)

    return CubicBezierScaffoldSegment(
        origin: origin, terminal: terminal,
        firstControlPoint: firstControlPoint,
        secondControlPoint: secondControlPoint)
  }
}