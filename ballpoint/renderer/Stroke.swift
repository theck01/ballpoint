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
      CGContextAddPath(context, p)
      CGContextSetRGBFillColor(context, red, green, blue, alpha)
      CGContextFillPath(context)
    }
  }
}



class MutableStroke: Stroke {
  init(color: UIColor) {
    super.init(paths: [], color: color)
  }
  
  
  /**
   Appends the path to the end of the stroke.

   :param: path The CGPath to append to the end of the stroke.
  */
  func appendPath(path: CGPath) {
    paths.append(path)
  }
}
