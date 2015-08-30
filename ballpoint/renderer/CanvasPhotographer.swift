//
//  CanvasBackingView.swift
//  inkwell
//
//  Created by Tyler Heck on 8/15/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class CanvasPhotographer {
  /// The array of strokes that compose the drawing.
  private var strokes: [Stroke] = []
  
  /// The image snapshot of the drawing.
  private(set) var snapshot: UIImage
  
  /// The size of the drawing in points.
  var imageSize: CGSize {
    didSet {
      snapshot = CanvasPhotographer.generateImageWithSize(
          imageSize, fromStrokes: strokes, previousImage: nil)
    }
  }
  
  
  init(imageSize: CGSize) {
    self.imageSize = imageSize
    snapshot = CanvasPhotographer.generateImageWithSize(
        imageSize, fromStrokes: [], previousImage: nil)
  }
  
  
  func addStrokeToSnapshot(stroke: Stroke) {
    strokes.append(stroke)
    snapshot = CanvasPhotographer.generateImageWithSize(
        imageSize, fromStrokes: [stroke], previousImage: snapshot)
  }


  func clearSnapshot() {
    strokes = []
    snapshot = CanvasPhotographer.generateImageWithSize(
        imageSize, fromStrokes: strokes, previousImage: nil)
  }
  
  
  private static func generateImageWithSize(
      size: CGSize, fromStrokes strokes: [Stroke],
      previousImage: UIImage?) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
    // Draw image on the new context, using -drawInRect to ensure that the
    // image is oriented properly within the context.
    previousImage?.drawInRect(CGRect(origin: CGPointZero, size: size))
        
    // Draw remaining strokes directly on the bitmap context.
    let bmpContext: CGContextRef = UIGraphicsGetCurrentContext()
    for s in strokes {
      s.paintOn(bmpContext)
    }
        
    let snapshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
        
    return snapshot
  }
}
