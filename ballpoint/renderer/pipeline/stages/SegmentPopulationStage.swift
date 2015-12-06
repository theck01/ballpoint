//
//  SegmentPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/24/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// Creates render segments between all existing render points within a
/// scaffold.
struct SegmentPopulationStage: RenderPipelineStage {
  func process(inout scaffold: RenderScaffold, stroke: Stroke) {
    for i in 0..<(scaffold.points.count - 1) {
      let previousPoint: ScaffoldPoint? = i > 0 ? scaffold.points[i - 1] : nil
      let nextPoint: ScaffoldPoint? =
          i < scaffold.points.count - 2 ? scaffold.points[i - 1] : nil

      let segmentA = ScaffoldSegmentFactory.generateSegment(
          previousPoint: previousPoint?.a, origin: scaffold.points[i].a,
          terminal: scaffold.points[i + 1].a, nextPoint: nextPoint?.a)
      let segmentB = ScaffoldSegmentFactory.generateSegment(
          previousPoint: nextPoint?.b, origin: scaffold.points[i + 1].b,
          terminal: scaffold.points[i].b, nextPoint: previousPoint?.b)

      scaffold.segmentPairs.append((a: segmentA, b: segmentB))
    }
  }
}
