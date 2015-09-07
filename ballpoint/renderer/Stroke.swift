//
//  Stroke.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// An identifier for a given stroke. Used to ensure that strokes are painted
/// only when necessary.
typealias StrokeId = UInt



/// An aggregation of CGPath objects making up one drawing stroke.
class Stroke {
  /// The array of paths that compose the stroke.
  private var paths: [CGPath]
  
  /// The color components of the stroke.
  private let red: CGFloat
  private let green: CGFloat
  private let blue: CGFloat
  private let alpha: CGFloat
  
  /// The identifier of the stroke.
  let id: StrokeId
  
  /// The global counter of stroke IDs.
  private static var strokeIdCounter: StrokeId = 0

  /// The revision that the stroke has been drawing on, or nil if the stroke has
  /// yet to be painted.
  private var paintedRevision: DrawingRenderer.RenderRevisionId?

  /// The bounding rect completely containing the stroke.
  private(set) var boundingRect: CGRect = CGRectNull
  
  
  init(paths: [CGPath], color: UIColor) {
    self.paths = paths
    
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    red = r
    green = g
    blue = b
    alpha = a
    
    id = Stroke.strokeIdCounter++
  }


  /**
   Paints self onto the given graphics context.

   :param: context The graphics context on which to paint.
   */
  func paintOn(context: CGContext) {
    for p in paths {
      paintCGPath(p, onContext: context)
    }
  }


  /**
   Paints self onto the given graphics context, skipping painting if the stroke
   has already been painted at the given revision.
  
   :param: context The graphics context on which to paint.
   :param: renderRevisionId
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
    CGContextSetRGBFillColor(context, red, green, blue, alpha)
    CGContextFillPath(context)
  }
}



class MutableStroke: Stroke {
  /// The paths of the stroke that still have not been painted on the canvas
  /// with the given ID.
  var dirtyPaths: [CGPath] = []

  /// The bounding rectangle around the dirty paths.
  private(set) var dirtyBoundingRect: CGRect = CGRectNull


  init(color: UIColor) {
    super.init(paths: [], color: color)
  }


  
  /**
   Appends the path to the end of the stroke.

   :param: path The CGPath to append to the end of the stroke.
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
