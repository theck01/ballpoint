//
//  QuadraticBezierScaffoldSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/29/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



struct QuadraticBezierScaffoldSegment: ScaffoldSegment {
  private let start: CGPoint
  private let end: CGPoint
  private let controlPoint: CGPoint

  var origin: CGPoint { return start }
  var terminal: CGPoint { return end }


  init(origin: CGPoint, terminal: CGPoint, controlPoint: CGPoint) {
    start = origin
    end = terminal
    self.controlPoint = controlPoint
  }


  func extendPath(path: CGMutablePath) {
    if CGPathIsEmpty(path) {
      CGPathMoveToPoint(path, nil, start.x, start.y)
    }

    assert(
        CGPathGetCurrentPoint(path) == start,
        "Cannot extend a path that is not currently at the expected path " +
        "starting point")
    CGPathAddQuadCurveToPoint(
        path, nil, controlPoint.x, controlPoint.y, end.x, end.y)
  }
}
