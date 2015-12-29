//
//  QuadraticBezierScaffoldSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/29/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A cubic bezier curve connection between ScaffoldPoints.
struct CubicBezierScaffoldSegment: ScaffoldSegment {
  private let start: CGPoint
  private let end: CGPoint
  private let firstControlPoint: CGPoint
  private let secondControlPoint: CGPoint

  var origin: CGPoint { return start }
  var terminal: CGPoint { return end }


  init(
      origin: CGPoint, terminal: CGPoint, firstControlPoint: CGPoint,
      secondControlPoint: CGPoint) {
    start = origin
    end = terminal
    self.firstControlPoint = firstControlPoint
    self.secondControlPoint = secondControlPoint
  }


  func extendPath(path: CGMutablePath) {
    if CGPathIsEmpty(path) {
      CGPathMoveToPoint(path, nil, start.x, start.y)
    }

    assert(
        CGPathGetCurrentPoint(path) =~= start,
        "Cannot extend a path that is not currently at the expected path " +
        "starting point")
    CGPathAddCurveToPoint(
        path, nil, firstControlPoint.x, firstControlPoint.y,
        secondControlPoint.x, secondControlPoint.y, end.x, end.y)
  }
}
