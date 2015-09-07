//
//  DrawingRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// The object responsible for rendering strokes on a bitmap. One renderer
/// should be used per revision.
class DrawingRenderer {
  typealias RenderRevisionId = Int

  private static var defaultEmptyRenderedDrawingInstance_: UIImage?

  static var kEmptyRenderedDrawing: UIImage {
    if defaultEmptyRenderedDrawingInstance_ == nil {
      UIGraphicsBeginImageContextWithOptions(Constants.kDrawingSize, false, 0.0)
      defaultEmptyRenderedDrawingInstance_ =
          UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    }

    return defaultEmptyRenderedDrawingInstance_!
  }

  /// The global counter of revision IDs, such that no two IDs are duplicates.
  private static var nextRevisionId: RenderRevisionId = 0

  /// The current renderer's revision number.
  var currentRevisionId: RenderRevisionId


  init() {
    currentRevisionId = DrawingRenderer.nextRevisionId++
  }


  func renderStrokes(
      strokes: [Stroke], onImage image: UIImage? = nil) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(Constants.kDrawingSize, false, 0.0)

    // Draw image on the new context, using -drawInRect to ensure that the
    // image is oriented properly within the context.
    image?.drawInRect(CGRect(origin: CGPointZero, size: Constants.kDrawingSize))

    // Draw remaining strokes directly on the bitmap context.
    let bmpContext: CGContextRef = UIGraphicsGetCurrentContext()
    for s in strokes {
      s.paintOn(bmpContext, renderRevisionId: currentRevisionId)
    }

    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return snapshot
  }


  func incrementRevision() {
    currentRevisionId = DrawingRenderer.nextRevisionId++
  }
}
