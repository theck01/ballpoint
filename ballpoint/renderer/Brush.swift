//
//  Brush.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



protocol Brush {
  /**
   Begins a new mutable stroke at the given location.

   - parameter location: The location at which to begin the stroke.
   */
  func beginStrokeWithColor(
      color: RendererColor, atLocation location: CGPoint) -> MutableStroke
  
  
  /**
   Extends the stroke between the given locations.

   - parameter stroke: The stroke to extend.
   - parameter fromLocation: The location where the brush begins.
   - parameter toLocation: The location to extend the stroke to.
   */
  func extendStroke(
      stroke: MutableStroke, fromLocation: CGPoint, toLocation: CGPoint)
}
