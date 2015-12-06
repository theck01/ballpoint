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
    if scaffold.points.count == 0 {
      return
    }

    scaffold.startCapSegment = LinearScaffoldSegment(
        origin: scaffold.points[0].b, terminal: scaffold.points[0].a)
    scaffold.endCapSegment = LinearScaffoldSegment(
        origin: scaffold.points.last!.a, terminal: scaffold.points.last!.b)
  }
}