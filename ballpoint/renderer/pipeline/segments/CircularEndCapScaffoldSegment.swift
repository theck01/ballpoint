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
  fileprivate let start: CGPoint
  fileprivate let end: CGPoint
  fileprivate let strokeDirection: DirectedLine

  var origin: CGPoint { return start }
  var terminal: CGPoint { return end }

  
  init(origin: CGPoint, terminal: CGPoint, strokeDirection: DirectedLine) {
    start = origin
    end = terminal
    self.strokeDirection = strokeDirection
  }


  func extendPath(_ path: CGMutablePath) {
    if path.isEmpty {
      path.move(to: start)
    }

    assert(
        path.currentPoint =~= start,
        "Cannot extend a path that is not currently at the expected path " +
        "starting point")

    guard let segment = LineSegment(point: start, otherPoint: end) else {
      return
    }
    let arcCenter = LineSegment.midpoint(segment)
    let radius = PointUtil.distance(start, end) / 2
    let vector = CGVector(dx: start.x - end.x, dy: start.y - end.y)
    let startAngle = vector.angleInRadians
    var angleDelta: CGFloat
    if DirectedLine.orientationOfPoint(start, toLine: strokeDirection) ==
        DirectedLine.Orientation.left {
      angleDelta = -CGFloat(M_PI)
    } else {
      angleDelta = CGFloat(M_PI)
    }
    path.addRelativeArc(
        center: arcCenter, radius: radius, startAngle: startAngle,
        delta: angleDelta)

    assert(
        path.currentPoint =~= end,
        "Should not extend a path to end at a different location then the " +
        "terminal of this segment.")
  }
}
