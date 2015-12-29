//
//  LinearScaffoldSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A linear connection between ScaffoldPoints.
struct LinearScaffoldSegment: ScaffoldSegment {
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
    CGPathAddLineToPoint(path, nil, end.x, end.y)
  }
}
