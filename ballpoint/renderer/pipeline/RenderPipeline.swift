//
//  RendererPipeline.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A pipeline that transforms model strokes into renderer strokes.
class RenderPipeline {
  private let stages: [RenderPipelineStage]


  init(stages: RenderPipelineStage...) {
    self.stages = stages
  }


  /**
   - parameter stroke:

   - returns: The model stroke rendered as a CGPath.
   */
  func render(stroke: Stroke) -> CGPath {
    var scaffold = RenderScaffold()
    for s in stages {
      s.process(&scaffold)
    }

    assert(
        scaffold.doesDescribeCompleteStroke,
        "Cannot render a RenderScaffold that does not describe a complete " +
        "stroke.")
    
    let path = CGPathCreateMutable()
    for segment in scaffold.segments {
      segment.extendPath(path)
    }
    return path
  }
}



/// Interface for a single stage within the renderer pipeline.
protocol RenderPipelineStage {
  /**
   - parameter scaffold: The partially constructed renderer scaffold. Stages
       should update the scaffold in place.
   */
  func process(inout scaffold: RenderScaffold, stroke: Stroke)
}
