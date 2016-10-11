//
//  StrokeRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit


/// Interface for a stroke renderer that only renders the specified strokes. The
/// renderer will not persist renderings between calls.
protocol StrokeRenderer {
  /**
   Renders the given strokes.

   - parameter strokes: The strokes with renderings to be updated.
   */
  func renderStrokes(_ strokes: [Stroke])
}
