//
//  EndcapPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/6/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



struct EndcapPopulationStage: RenderPipelineStage {
  func process(inout scaffold: RenderScaffold, stroke: Stroke) {
    // If the scaffold is empty then do nothing.
    if scaffold.segmentPairs.count == 0 {
      return
    }

    scaffold.startCapSegment = LinearScaffoldSegment(
        origin: scaffold.segmentPairs[0].b.terminal,
        terminal: scaffold.segmentPairs[0].a.origin)
    scaffold.endCapSegment = LinearScaffoldSegment(
        origin: scaffold.segmentPairs.last!.a.terminal,
        terminal: scaffold.segmentPairs.last!.b.origin)
  }
}