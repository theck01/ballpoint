//
//  RenderPipelineStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 1/10/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//



/// Interface for a single stage within the renderer pipeline.
protocol RenderPipelineStage {
  /**
   - parameter scaffold: The partially constructed renderer scaffold. Stages
       should update the scaffold in place.
   */
  func process(inout scaffold: RenderScaffold, stroke: Stroke)
}