//
//  EndcapPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/6/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



struct EndcapPopulationStage: RenderPipelineStage {
  func process(_ scaffold: inout RenderScaffold, stroke: Stroke) {
    // If the scaffold is empty then do nothing.
    if scaffold.segmentPairs.count == 0 {
      return
    }

    assert(
      stroke.points.count > 1,
      "Assumption that stroke has more than one point is false.")

    if let startDirectedLine = DirectedLine(
        earlyPoint: stroke.points[1].location,
        latePoint: stroke.points[0].location) {
      scaffold.startCapSegment = CircularEndCapScaffoldSegment(
          origin: scaffold.segmentPairs[0].right.terminal,
          terminal: scaffold.segmentPairs[0].left.origin,
          strokeDirection: startDirectedLine)
    }

    if let endDirectedLine = DirectedLine(
        earlyPoint: stroke.points[stroke.points.count - 2].location,
        latePoint: stroke.points.last!.location) {
      scaffold.endCapSegment = CircularEndCapScaffoldSegment(
          origin: scaffold.segmentPairs.last!.left.terminal,
          terminal: scaffold.segmentPairs.last!.right.origin,
          strokeDirection: endDirectedLine)
    }
  }
}
