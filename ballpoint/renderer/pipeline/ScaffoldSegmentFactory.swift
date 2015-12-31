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
    if let pointSegment =
        maybeCreatePointSegment(origin: origin, terminal: terminal) {
      return pointSegment
    }

    if let quadraticSegment = maybeCreateQuadraticBezierSegment(
        previousPoint: previousPoint, origin: origin, terminal: terminal,
        nextPoint: nextPoint) {
      return quadraticSegment
    }

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
    return nil
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
    return nil
  }
}