//
//  ScaffoldSegmentFactory.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/6/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



struct ScaffoldSegmentFactory {
  static func generateSegment(
      previousPoint previousPoint: CGPoint?, origin: CGPoint, terminal: CGPoint,
      nextPoint: CGPoint?) -> ScaffoldSegment {
    return LinearScaffoldSegment(origin: origin, terminal: terminal)
  }
}