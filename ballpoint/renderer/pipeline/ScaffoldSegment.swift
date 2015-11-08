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
  /// The start location of the scaffold segment.
  var origin: CGPoint { get }

  /// The end location of the scaffold segment.
  var terminal: CGPoint { get }
  
  /**
   - parameter path: The path to extend with the scaffold's path.
   */
  func extendPath(path: CGMutablePath)
}
