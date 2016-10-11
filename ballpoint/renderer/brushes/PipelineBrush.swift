//
//  PipelineBrush.swift
//  ballpoint
//
//  Created by Tyler Heck on 12/6/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



class PipelineBrush: Brush {
  fileprivate let pipeline: RenderPipeline = RenderPipeline(stages:
      PointPopulationStage(), SegmentPopulationStage(), EndcapPopulationStage())

  func render(_ stroke: Stroke) -> RenderedStroke? {
    return RenderedStroke(paths: pipeline.render(stroke))
  }
}
