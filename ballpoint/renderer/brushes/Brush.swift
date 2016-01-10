//
//  Brush.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



protocol Brush {
  var renderDebugPaths: Bool { get set }


  /**
   - parameter stroke:

   - returns: The rendered stroke, if the stroke could be rendered.
   */
  func render(stroke: Stroke) -> RenderedStroke?
}
