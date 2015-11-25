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
class SegmentPopulationStage: RenderPipelineStage {
  func process(inout scaffold: RenderScaffold, stroke: Stroke) {
    for i in 0..<(scaffold.points.count - 1) {
      scaffold.segmentPairs.append((
        a: LinearScaffoldSegment(
            origin: scaffold.points[i].a,
            terminal: scaffold.points[i + 1].a),
        b: LinearScaffoldSegment(
            origin: scaffold.points[i + 1].b,
            terminal: scaffold.points[i].b)
      ))
    }
  }
}
