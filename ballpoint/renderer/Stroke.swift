//
//  Stroke.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// An aggregation of CGPath objects making up one drawing stroke.
class Stroke {
  /// The array of paths that compose the stroke.
  private var paths: [CGPath]
  
  /// The color of the stroke.
  private let color: RendererColor

  /// The bounding rect completely containing the stroke.
  private(set) var boundingRect: CGRect = CGRectNull
  
  
  init(paths: [CGPath], color: RendererColor) {
    self.paths = paths
    self.color = color
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



class MutableStroke: Stroke {
  init(color: RendererColor) {
    super.init(paths: [], color: color)
  }


  /**
   Appends the path to the end of the stroke.

   - parameter path: The CGPath to append to the end of the stroke.
  */
  func appendPath(path: CGPath) {
    paths.append(path)
    boundingRect = CGRectUnion(
        boundingRect, CGPathGetBoundingBox(path))
  }
}
