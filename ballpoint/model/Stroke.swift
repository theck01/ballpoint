//
//  Stroke.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/27/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



class Stroke {
  /// The points that form the path that was followed to compose the stroke.
  private(set) var points: [CGPoint]

  /// The color of the stroke.
  let color: RendererColor

  /// The brush used to render the stroke.
  let brush: Brush


  private init(points: [CGPoint], color: RendererColor, brush: Brush) {
    self.points = points
    self.color = color
    self.brush = brush
  }
}



class MutableStroke: Stroke {
  init(color: RendererColor, brush: Brush) {
    super.init(points: [], color: color, brush: brush)
  }


  func appendPoint(p: CGPoint) {
    points.append(p)
  }
}
