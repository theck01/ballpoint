//
//  RendererPipeline.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// A pipeline that transforms model strokes into renderer strokes.
class RenderPipeline {
  private let stages: [RenderPipelineStage]

  var renderDebugPaths: Bool = false


  init(stages: RenderPipelineStage...) {
    self.stages = stages
  }


  /**
   - parameter stroke:

   - returns: The model stroke rendered as a CGPath.
   */
  func render(stroke: Stroke) -> [RenderedStroke.Path] {
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

    var renderedPaths: [RenderedStroke.Path] = []
    renderedPaths.append(RenderedStroke.Path(
        cgPath: path, color: stroke.color.backingColor,
        mode: CGPathDrawingMode.Fill))

    if renderDebugPaths {
      renderedPaths += renderDebugPaths(scaffold)
    }

    return renderedPaths
  }


  /**
   - parameter scaffold:

   - returns: The set of debug paths generated from the render scaffold.
   */
  func renderDebugPaths(scaffold: RenderScaffold) -> [RenderedStroke.Path] {
    var debugPaths: [RenderedStroke.Path] = []
    return debugPaths
  }
}
