//
//  Stroke.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// An aggregation of CGPath objects making up one rendered drawing stroke.
struct RendererStroke {
  /// The array of paths that compose the stroke.
  private let paths: [CGPath]
  
  /// The color of the stroke.
  private let color: RendererColor

  /// The bounding rect completely containing the stroke.
  let boundingRect: CGRect
  
  
  init(paths: [CGPath], color: RendererColor) {
    self.paths = paths
    self.color = color
    boundingRect = paths.reduce(CGRectNull) { (rect: CGRect, p: CGPath) in
      return CGRectUnion(rect, CGPathGetBoundingBox(p))
    }
  }


  /**
   Paints self onto the given graphics context.

   - parameter context: The graphics context on which to paint.
   */
  func paintOn(context: CGContext) {
    for p in paths {
      paintCGPath(p, onContext: context)
    }
  }


  private func paintCGPath(path: CGPath, onContext context: CGContext) {
    CGContextAddPath(context, path)
    CGContextSetRGBFillColor(
        context, color.red, color.green, color.blue, color.alpha)
    CGContextFillPath(context)
  }
}
