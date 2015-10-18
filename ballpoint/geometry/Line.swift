//
//  Line.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/4/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A structure representation of a line.
struct Line {
  /// lhe slope of the line.
  let slope: CGFloat

  /// The y intercept of the line, or nil if the line is vertical and does not
  /// intersect with the y-axis.
  let yIntercept: CGFloat?

  /// The x intercept of the line, or nil if the line is horizontal and does not
  /// intersect with the x-axis.
  let xIntercept: CGFloat?

  /// Whether the line is vertical.
  var isVertical: Bool {
    return yIntercept == nil
  }

  /// Whether the line is horizontal.
  var isHorizontal: Bool {
    return xIntercept == nil
  }


  init(point a: CGPoint, otherPoint b: CGPoint) {
    if a.x.roughlyEquals(b.x) && a.y.roughlyEquals(b.y) {
      fatalError("Cannot create a line from identical points")
    }

    if a.x.roughlyEquals(b.x) {
      self.init(slope: CGFloat.max, throughPoint: a)
    } else {
      self.init(slope: (a.y - b.y) / (a.x - b.x), throughPoint: a)
    }
  }


  init(slope: CGFloat, throughPoint p: CGPoint) {
    if slope == CGFloat.max {
      self.init(slope: slope, xIntercept: p.x, yIntercept: nil)
    } else if slope == 0 {
      self.init(slope: slope, xIntercept: nil, yIntercept: p.y)
    } else {
      let lineYIntercept = p.y - slope * p.x
      let lineXIntercept = -1 * (lineYIntercept / slope)
      self.init(
          slope: slope, xIntercept: lineXIntercept, yIntercept: lineYIntercept)
    }
  }


  private init(slope: CGFloat, xIntercept: CGFloat?, yIntercept: CGFloat?) {
    if slope == 0 {
      assert(
          xIntercept == nil,
          "Cannot have a x intercept for a completely horizontal line.")
    }

    if xIntercept == nil {
      assert(
          slope == 0,
          "A missing x intercept can only be associated with a vertical line.")
    }

    if slope == CGFloat.max {
      assert(
          yIntercept == nil,
          "Cannot have a y intercept for a completely vertical line.")
    }

    if yIntercept == nil {
      assert(
          slope == CGFloat.max,
          "A missing y intercept can only be associated with a vertical line.")
    }

    self.slope = slope
    self.xIntercept = xIntercept
    self.yIntercept = yIntercept
  }
}



/// Collection of static methods for operating on Line objects.
extension Line {
  /**
  - parameter a:
  - parameter b:

  - returns: The intersection point between the two lines, or nil if the lines
      are parallel and do not intersect.
  */
  static func intersection(a: Line, _ b: Line) -> CGPoint? {
    if a.slope.roughlyEquals(b.slope) {
      return nil
    }

    var xIntersection: CGFloat
    if a.yIntercept == nil {
      xIntersection = a.xIntercept!
    } else if b.yIntercept == nil {
      xIntersection = b.xIntercept!
    } else {
      xIntersection = (a.yIntercept! - b.yIntercept!) / (b.slope - a.slope)
    }

    var yIntersection: CGFloat
    if a.xIntercept == nil {
      yIntersection = a.yIntercept!
    } else if b.xIntercept == nil {
      yIntersection = b.yIntercept!
    } else {
      if a.yIntercept != nil {
        yIntersection = a.slope * xIntersection + a.yIntercept!
      } else {
        yIntersection = b.slope * xIntersection + b.yIntercept!
      }
    }

    return CGPoint(x: xIntersection, y: yIntersection)
  }


  /**
  - parameter point:
  - parameter line:

  - returns: Whether the point is on the line.
  */
  static func isPoint(point: CGPoint, onLine line: Line) -> Bool {
    if line.isVertical {
      guard let xIntercept = line.xIntercept else {
        fatalError("A vertical line must have an x-intercept.")
      }
      return point.x.roughlyEquals(xIntercept)
    }

    guard let yIntercept = line.yIntercept else {
      fatalError("A non-vertical line must have a y-intercept")
    }
    let yForPointX = line.slope * point.x + yIntercept
    return yForPointX.roughlyEquals(point.y)
  }


  /**
  - parameter distance:
  - parameter line:
  - parameter point: A point that is asserted to be on the line.

  - returns: Returns the two points that are the given distance away from the
      point on the line.
  */
  static func pointsAtDistance(
      distance: CGFloat, onLine line: Line, fromPoint point: CGPoint) ->
      (p1: CGPoint, p2: CGPoint) {
    assert(
        isPoint(point, onLine: line),
        "Cannot get the points that are a distance from a point not on the " +
        "argument line.")
    fatalError("Method not yet implemented.")
  }
}
