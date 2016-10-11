//
//  QuadraticBezierScaffoldSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/29/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A quadratic bezier curve connection between ScaffoldPoints.
struct QuadraticBezierScaffoldSegment: ScaffoldSegment {
  fileprivate let start: CGPoint
  fileprivate let end: CGPoint
  fileprivate let controlPoint: CGPoint

  var origin: CGPoint { return start }
  var terminal: CGPoint { return end }


  init(origin: CGPoint, terminal: CGPoint, controlPoint: CGPoint) {
    start = origin
    end = terminal
    self.controlPoint = controlPoint
  }


  func extendPath(_ path: CGMutablePath) {
    if path.isEmpty {
      path.move(to: start)
    }

    assert(
        path.currentPoint =~= start,
        "Cannot extend a path that is not currently at the expected path " +
        "starting point")
    path.addQuadCurve(to: end, control: controlPoint)
  }
}
