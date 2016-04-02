//
//  CircularEndCapScaffoldSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 4/2/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A circular connection between ScaffoldPoints.
struct CircularEndCapScaffoldSegment: ScaffoldSegment {
  private let start: CGPoint
  private let end: CGPoint

  var origin: CGPoint { return start }
  var terminal: CGPoint { return end }

  
  init(origin: CGPoint, terminal: CGPoint) {
    start = origin
    end = terminal
  }


  func extendPath(path: CGMutablePath) {
    if CGPathIsEmpty(path) {
      CGPathMoveToPoint(path, nil, start.x, start.y)
    }

    assert(
        CGPathGetCurrentPoint(path) =~= start,
        "Cannot extend a path that is not currently at the expected path " +
        "starting point")

    guard let segment = LineSegment(point: start, otherPoint: end) else {
      return
    }
    let arcCenter = LineSegment.midpoint(segment)
    let radius = PointUtil.distance(start, end) / 2
    let vector = CGVectorMake(start.x - end.x, start.y - end.y)
    let startAngle = vector.angleInRadians
    CGPathAddRelativeArc(
        path, nil, arcCenter.x, arcCenter.y, radius, startAngle,
        3 * CGFloat(M_PI))

    assert(
        CGPathGetCurrentPoint(path) =~= end,
        "Should not extend a path to end at a different location then the " +
        "terminal of this segment.")
  }
}