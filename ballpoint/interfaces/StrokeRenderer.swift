//
//  StrokeRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit

protocol StrokeRenderer {
  /**
   Updates the rendering of the given strokes.

   - parameter strokes: The strokes with renderings to be updated.
   */
  func updateRenderingStrokes(strokes: [MutableStroke])

  /**
   Completes the rendering of the given strokes without affecting the rendering
   of remaining strokes.

   - parameter strokes: The strokes with renderings to be updated.
   */
  func completeRenderingStrokes(strokes: [Stroke])

  /**
   Cancels the rendering of all displayed strokes.
   */
  func cancelRenderingStrokes()
}
