//
//  PointScaffoldSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/29/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A zero-length connection between ScaffoldPoints.
struct PointScaffoldSegment: ScaffoldSegment {
  private let point: CGPoint

  var origin: CGPoint { return point }
  var terminal: CGPoint { return point }

  init(point: CGPoint) {
    self.point = point
  }


  func extendPath(path: CGMutablePath) {
    if CGPathIsEmpty(path) {
      CGPathMoveToPoint(path, nil, point.x, point.y)
    }
    assert(
        CGPathGetCurrentPoint(path) =~= point,
        "Cannot extend a path that is not currently at the expected path " +
        "starting point")
  }
}