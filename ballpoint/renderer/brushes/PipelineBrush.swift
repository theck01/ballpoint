//
//  PipelineBrush.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/6/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



class PipelineBrush: Brush {
  var renderDebugPaths: Bool {
    get {
      return pipeline.renderDebugPaths
    }
    set {
      pipeline.renderDebugPaths = newValue
    }
  }

  private let pipeline: RenderPipeline = RenderPipeline(stages:
      PointPopulationStage(), SegmentPopulationStage(), EndcapPopulationStage())

  func render(stroke: Stroke) -> RenderedStroke? {
    return RenderedStroke(paths: pipeline.render(stroke))
  }
}
