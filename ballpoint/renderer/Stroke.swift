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

  /// The revision that the stroke has been drawing on, or nil if the stroke has
  /// yet to be painted.
  private var paintedRevision: DrawingRenderer.RenderRevisionId?

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


  /**
   Paints self onto the given graphics context, skipping painting if the stroke
   has already been painted at the given revision.
  
   - parameter context: The graphics context on which to paint.
   - parameter renderRevisionId:
   */
  func paintOn(
      context: CGContext,
      renderRevisionId: DrawingRenderer.RenderRevisionId) {
    if paintedRevision == renderRevisionId {
      return
    }

    paintOn(context)
  }


  private func paintCGPath(path: CGPath, onContext context: CGContext) {
    CGContextAddPath(context, path)
    CGContextSetRGBFillColor(
        context, color.red, color.green, color.blue, color.alpha)
    CGContextFillPath(context)
  }
}



class MutableStroke: Stroke {
  /// The paths of the stroke that still have not been painted on the canvas
  /// with the given ID.
  var dirtyPaths: [CGPath] = []

  /// The bounding rectangle around the dirty paths.
  private(set) var dirtyBoundingRect: CGRect = CGRectNull


  init(color: RendererColor) {
    super.init(paths: [], color: color)
  }


  
  /**
   Appends the path to the end of the stroke.

   - parameter path: The CGPath to append to the end of the stroke.
  */
  func appendPath(path: CGPath) {
    paths.append(path)
    dirtyPaths.append(path)

    let pathRect = CGPathGetBoundingBox(path)

    dirtyBoundingRect = CGRectUnion(dirtyBoundingRect, pathRect)
    boundingRect = CGRectUnion(boundingRect, pathRect)
  }


  override func paintOn(context: CGContext) {
    super.paintOn(context)
    dirtyPaths = []
    dirtyBoundingRect = CGRectNull
  }


  override func paintOn(
      context: CGContext, renderRevisionId: DrawingRenderer.RenderRevisionId) {
    if paintedRevision == renderRevisionId {
      for p in dirtyPaths {
        paintCGPath(p, onContext: context)
      }
    } else {
      super.paintOn(context, renderRevisionId: renderRevisionId)
    }
        
    dirtyPaths = []
    dirtyBoundingRect = CGRectNull
  }
}
