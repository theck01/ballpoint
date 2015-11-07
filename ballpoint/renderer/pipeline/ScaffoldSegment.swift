//
//  ScaffoldSegment.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// Interface for a segment that connects two ScaffoldPoints.
protocol ScaffoldSegment {
  /**
   - parameter path: The path to extend with the scaffold's path.
   */
  func extendPath(path: CGMutablePath)
}
