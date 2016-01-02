//
//  Stroke.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/27/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics


struct StrokePoint {
  let location: CGPoint
  let sizeModifier: CGFloat


  init(location: CGPoint) {
    self.init(location: location, sizeModifier: 1)
  }


  init(location: CGPoint, sizeModifier: CGFloat) {
    self.location = location
    self.sizeModifier = sizeModifier
  }
}


class Stroke {
  /// The points that form the path that was followed to compose the stroke.
  private(set) var points: [StrokePoint]

  /// The color of the stroke.
  let color: RendererColor

  /// The brush used to render the stroke.
  let brush: Brush


  private init(points: [StrokePoint], color: RendererColor, brush: Brush) {
    self.points = points
    self.color = color
    self.brush = brush
  }
}



class MutableStroke: Stroke {
  init(color: RendererColor, brush: Brush) {
    super.init(points: [], color: color, brush: brush)
  }


  func appendPoint(p: StrokePoint) {
    // Don't append identical points to the end of the stroke.
    if points.count > 0 && points.last!.location =~= p.location {
      return
    }

    points.append(p)
  }
}
