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
  struct Path {
    let cgPath: CGPath
    let color: UIColor
    let mode: CGPathDrawingMode
  }

  /// The array of paths and colors that compose the stroke.
  fileprivate let paths: [Path]
  
  /// The bounding rect completely containing the stroke.
  let boundingRect: CGRect
  
  
  init(paths: [Path]) {
    self.paths = paths
    boundingRect = paths.reduce(CGRect.null) {
        (rect: CGRect, p: Path) in
      return rect.union(p.cgPath.boundingBox)
    }
  }


  /**
   Paints self onto the given graphics context.

   - parameter context: The graphics context on which to paint.
   */
  func paintOn(_ context: CGContext) {
    for p in paths {
      paintPath(p, onContext: context)
    }
  }


  fileprivate func paintPath(
      _ path: Path, onContext context: CGContext) {
    context.addPath(path.cgPath)

    let colorComponents = path.color.components()
    context.setFillColor(red: colorComponents.red, green: colorComponents.green,
        blue: colorComponents.blue, alpha: colorComponents.alpha)
    context.setStrokeColor(red: colorComponents.red, green: colorComponents.green,
        blue: colorComponents.blue, alpha: colorComponents.alpha)

    context.drawPath(using: path.mode)
  }
}
