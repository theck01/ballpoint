//
//  DrawingRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingRenderer {
  static func renderStrokes(
      strokes: [Stroke], withinSize size: CGSize,
      onImage image: UIImage? = nil) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

    // Draw image on the new context, using -drawInRect to ensure that the
    // image is oriented properly within the context.
    image?.drawInRect(CGRect(origin: CGPointZero, size: size))

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