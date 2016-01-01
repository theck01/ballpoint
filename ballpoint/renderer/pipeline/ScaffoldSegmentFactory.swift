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
   - parameter origin:
   - parameter terminal:

   - returns: A PointScaffoldSegment if the origin and terminal are roughly
       equivalent, or nil if not.
   */
  static func maybeCreatePointSegment(
      origin origin: CGPoint, terminal: CGPoint) -> PointScaffoldSegment? {
    return origin =~= terminal ? PointScaffoldSegment(point: origin) : nil
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
   
   - returns: The QuadraticBezierScaffoldSegment connecting the origin to the
       terminal, or nil if a quadratic bezier is not the appropriate connector
       for the origin and terminal.
   */
  static func maybeCreateQuadraticBezierSegment(
      previousPoint previousPoint: CGPoint?, origin: CGPoint, terminal: CGPoint,
      nextPoint: CGPoint?) -> QuadraticBezierScaffoldSegment? {
    // A next and previous point must exist in order to inform position of the
    // quadratic bezier control point.
    guard let previousPoint = previousPoint else { return nil }
    guard let nextPoint = nextPoint else { return nil }

    // Both the previous and next points must be on the same side of the line
    // between the segment points for a quadratic curve to apply to the segment.
    guard let segmentLine = Line(point: origin, otherPoint: terminal)
        else { return nil }
    guard Line.arePoints(
        (previousPoint, nextPoint), onSameSideOfLine: segmentLine)
        else { return nil }

    // If the previous and next segments intersect then a quadratic curve cannot
    // be applied, as the tangent lines for the origin and terminal are not
    // guaranteed to intersect to create a quadratic control point.
    guard let priorSegment =
        LineSegment(point: previousPoint, otherPoint: origin)
        else { return nil }
    guard let nextSegment =
        LineSegment(point: terminal, otherPoint: nextPoint)
        else { return nil }
    if LineSegment.intersection(priorSegment, nextSegment) != nil { return nil }

    // A quadratic bezier curve should connect the origin to the terminal. The
    // control point for this curve is located at the intersection of the
    // tangent lines to the curve at the origin and terminal.
    guard let originTangentSlopeLine =
        Line(point: previousPoint, otherPoint: terminal) else { return nil }
    guard let terminalTangentSlopeLine =
        Line(point: origin, otherPoint: nextPoint) else { return nil }
    let originTangentLine =
        Line(slope: originTangentSlopeLine.slope, throughPoint: origin)
    let terminalTangentLine =
        Line(slope: terminalTangentSlopeLine.slope, throughPoint: terminal)
    guard let controlPoint =
        Line.intersection(originTangentLine, terminalTangentLine)
      else { return nil }
        
    return QuadraticBezierScaffoldSegment(
        origin: origin, terminal: terminal, controlPoint: controlPoint)
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