//
//  StrokePoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 1/3/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
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