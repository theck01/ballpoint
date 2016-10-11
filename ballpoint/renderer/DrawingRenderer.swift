//
//  DrawingRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// The object responsible for rendering strokes on a bitmap.
class DrawingRenderer {
  /// The size of the rendered output.
  fileprivate let drawingSize: CGSize

  /// An image containing a drawing composed of no strokes.
  let emptyDrawing: UIImage


  init(drawingSize: CGSize) {
    self.drawingSize = drawingSize

    UIGraphicsBeginImageContextWithOptions(drawingSize, false, 0)
    self.emptyDrawing = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
  }


  func renderStrokes(
      _ strokes: [Stroke], onImage image: UIImage? = nil) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(drawingSize, false, 0.0)

    // Draw image on the new context, using -drawInRect to ensure that the
    // image is oriented properly within the context.
    image?.draw(in: CGRect(origin: CGPoint.zero, size: drawingSize))

    // Draw remaining strokes directly on the bitmap context.
    if let bmpContext = UIGraphicsGetCurrentContext() {
      for s in strokes {
        if let renderedStroke = s.brush.render(s) {
          renderedStroke.paintOn(bmpContext)
        }
      }
    }

    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return snapshot!
  }
}
