//
//  PipelineBrush.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/6/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



struct PipelineBrush: Brush {
  private let pipeline: RenderPipeline = RenderPipeline(stages:
      PointPopulationStage(), SegmentPopulationStage(), EndcapPopulationStage())

  func render(stroke: Stroke) -> RenderedStroke? {
    return RenderedStroke(paths: pipeline.render(stroke))
  }
}
