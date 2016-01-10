//
//  Stroke.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// An aggregation of CGPath objects making up one rendered drawing stroke.
struct RenderedStroke {
  struct RenderedStrokePath {
    let cgPath: CGPath
    let color: UIColor
    let mode: CGPathDrawingMode
  }

  /// The array of paths and colors that compose the stroke.
  private let paths: [RenderedStrokePath]
  
  /// The bounding rect completely containing the stroke.
  let boundingRect: CGRect
  
  
  init(paths: [RenderedStrokePath]) {
    self.paths = paths
    boundingRect = paths.reduce(CGRectNull) {
        (rect: CGRect, p: RenderedStrokePath) in
      return CGRectUnion(rect, CGPathGetBoundingBox(p.cgPath))
    }
  }


  /**
   Paints self onto the given graphics context.

   - parameter context: The graphics context on which to paint.
   */
  func paintOn(context: CGContext) {
    for p in paths {
      paintPath(p, onContext: context)
    }
  }


  private func paintPath(
      path: RenderedStrokePath, onContext context: CGContext) {
    CGContextAddPath(context, path.cgPath)

    let colorComponents = path.color.components()
    CGContextSetRGBFillColor(
        context, colorComponents.red, colorComponents.green,
        colorComponents.blue, colorComponents.alpha)
    CGContextSetRGBFillColor(
        context, colorComponents.red, colorComponents.green,
        colorComponents.blue, colorComponents.alpha)

    CGContextDrawPath(context, path.mode)
  }
}
