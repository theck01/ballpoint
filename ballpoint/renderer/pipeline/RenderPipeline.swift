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
  // Colors used for debug paths.
  private static let kDebugStrokeOutlineColor = UIColor.orangeColor()
  private static let kDebugStrokeModelPointColor = UIColor.greenColor()
  private static let kDebugStrokeASidePointColor = UIColor.redColor()
  private static let kDebugStrokeBSidePointColor = UIColor.blueColor()

  private static let kDebugPointRadius: CGFloat = 1.5

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

    let path = CGPathCreateMutable()
    for segment in scaffold.segments {
      segment.extendPath(path)
    }
    CGPathCloseSubpath(path)
    debugPaths.append(RenderedStroke.Path(
        cgPath: path, color: RenderPipeline.kDebugStrokeOutlineColor,
        mode: CGPathDrawingMode.Stroke))

    for p in scaffold.points {
      debugPaths.append(RenderedStroke.Path(
          cgPath: circularPathAroundPoint(
              p.modelLocation, radius: RenderPipeline.kDebugPointRadius),
          color: RenderPipeline.kDebugStrokeModelPointColor,
          mode: CGPathDrawingMode.Fill))

      debugPaths.append(RenderedStroke.Path(
          cgPath: circularPathAroundPoint(
              p.a, radius: RenderPipeline.kDebugPointRadius),
          color: RenderPipeline.kDebugStrokeASidePointColor,
          mode: CGPathDrawingMode.Fill))

      debugPaths.append(RenderedStroke.Path(
          cgPath: circularPathAroundPoint(
              p.b, radius: RenderPipeline.kDebugPointRadius),
          color: RenderPipeline.kDebugStrokeBSidePointColor,
          mode: CGPathDrawingMode.Fill))
    }

    return debugPaths
  }


  private func circularPathAroundPoint(
      center: CGPoint, radius: CGFloat) -> CGPath {
    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, center.x + radius, center.y)
    CGPathAddArc(
        path, nil, center.x, center.y, radius, 0, 2 * CGFloat(M_PI), false)
    CGPathCloseSubpath(path)
    return path
  }
}
