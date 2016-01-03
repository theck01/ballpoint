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

  /// A value between 0 and 1 that indicates the size of a stroke at the point,
  /// between a minimum and maximum value.
  let sizeFactor: CGFloat


  init(location: CGPoint) {
    self.init(location: location, sizeFactor: 1)
  }


  init(location: CGPoint, sizeFactor: CGFloat) {
    self.location = location
    self.sizeFactor = sizeFactor
  }
}


class Stroke {
  /// The points that form the path that was followed to compose the stroke.
  private(set) var points: [StrokePoint]

  /// The color of the stroke.
  let color: RendererColor

  /// The brush used to render the stroke.
  let brush: Brush

  /// The minimum width of the stroke.
  let minimumWidth: CGFloat

  /// The maximum width of the stroke.
  let maximumWidth: CGFloat


  private init(
      points: [StrokePoint], color: RendererColor, brush: Brush,
      minimumWidth: CGFloat, maximumWidth: CGFloat) {
    self.points = points
    self.color = color
    self.brush = brush
    self.minimumWidth = minimumWidth
    self.maximumWidth = maximumWidth
  }
}



class MutableStroke: Stroke {
  init(
      color: RendererColor, brush: Brush, minimumWidth: CGFloat,
      maximumWidth: CGFloat) {
    super.init(
        points: [], color: color, brush: brush, minimumWidth: minimumWidth,
        maximumWidth: maximumWidth)
  }


  func appendPoint(p: StrokePoint) {
    // Don't append identical points to the end of the stroke.
    if points.count > 0 && points.last!.location =~= p.location {
      return
    }

    points.append(p)
  }
}
