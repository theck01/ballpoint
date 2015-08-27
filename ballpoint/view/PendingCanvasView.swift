//
//  Canvas.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// View that handles drawing pending strokes to the screen.
class PendingCanvasView: UIView {
  /// The map of strokes that require drawing.
  private var pendingStrokes: (ids: Set<StrokeId>, strokes: [Stroke]) =
      (ids: Set(), strokes: [])
  
  /// The current graphics context. Only valid during a -drawRect call, cached
  /// for speed.
  private var context: CGContext!
  
  
  /**
   Adds the given stroke as pending within the canvas view. Does nothing if the
   given stroke is already pending within the view.

   :param: stroke
   */
  func addPendingStroke(stroke: Stroke) {
    if !pendingStrokes.ids.contains(stroke.id) {
      pendingStrokes.ids.insert(stroke.id)
      pendingStrokes.strokes.append(stroke)
      
      setNeedsDisplay()
    }
  }
  
  
  override func drawRect(rect: CGRect) {
    // Only draw if needed.
    if pendingStrokes.strokes.count > 0 {
      context = UIGraphicsGetCurrentContext()
      
      for s in pendingStrokes.strokes {
        s.paintOn(context)
      }
      pendingStrokes = (ids: Set(), strokes: [])
      
      context = nil
    }
  }
}
