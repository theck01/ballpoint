//
//  RendererPipeline.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A pipeline that transforms model strokes into renderer strokes.
struct RenderPipeline {
  private let stages: [RenderPipelineStage]


  init(stages: RenderPipelineStage...) {
    self.stages = stages
  }


  /**
   - parameter stroke:

   - returns: The model stroke rendered as a CGPath.
   */
  func render(stroke: Stroke) -> [RenderedStroke.RenderedStrokePath] {
    var scaffold = RenderScaffold()
    for s in stages {
      s.process(&scaffold, stroke: stroke)
    }

    assert(
        scaffold.doesDescribeCompleteStroke,
        "Cannot render a RenderScaffold that does not describe a complete " +
        "stroke.")
    
    let path = CGPathCreateMutable()
    for segment in scaffold.segments {
      segment.extendPath(path)
    }
    CGPathCloseSubpath(path)

    let renderedPath = RenderedStroke.RenderedStrokePath(
        cgPath: path, color: stroke.color.backingColor,
        mode: CGPathDrawingMode.FillStroke)
    return [renderedPath]
  }
}
