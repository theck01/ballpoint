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
      let originTangentSlope = scaffold.points[i].modelTangentLine.slope
      let terminalTangentSlope = scaffold.points[i + 1].modelTangentLine.slope

      let segmentA = ScaffoldSegmentFactory.generateSegment(
          origin: scaffold.points[i].a,
          originTangentLine: Line(
              slope: originTangentSlope, throughPoint: scaffold.points[i].a),
          terminal: scaffold.points[i + 1].a,
          terminalTangentLine: Line(
              slope: terminalTangentSlope,
              throughPoint: scaffold.points[i + 1].a))

      let segmentB = ScaffoldSegmentFactory.generateSegment(
          origin: scaffold.points[i + 1].b,
          originTangentLine: Line(
              slope: terminalTangentSlope,
              throughPoint: scaffold.points[i + 1].b),
          terminal: scaffold.points[i].b,
          terminalTangentLine: Line(
              slope: originTangentSlope, throughPoint: scaffold.points[i].b))

      scaffold.segmentPairs.append((a: segmentA, b: segmentB))
    }
  }
}
