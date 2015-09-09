//
//  UIColor+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/26/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



extension UIColor {
  /// The backing instance for -launchScreenBackgroundColor
  private static var _launchScreenBackgroundColor: UIColor?

  /// The backing instance for -ballpointInkColor
  private static var _ballpointInkColor: UIColor?

  /// The backing instance for -ballpointSurfaceColor
  private static var _ballpointSurfaceColor: UIColor?


  static func launchScreenBackgroundColor() -> UIColor {
    if _launchScreenBackgroundColor == nil {
      _launchScreenBackgroundColor = UIColor(white: 0.733, alpha: 1)
    }
    return _launchScreenBackgroundColor!
  }
  

  static func ballpointInkColor() -> UIColor {
    if _ballpointInkColor == nil {
      _ballpointInkColor = UIColor(
          red: 0.004, green: 0.083, blue: 0.116, alpha: 1)
    }
    return _ballpointInkColor!
  }

  static func ballpointSurfaceColor() -> UIColor {
    if _ballpointSurfaceColor == nil {
      _ballpointSurfaceColor = UIColor(white: 1, alpha: 1)
    }
    return _ballpointSurfaceColor!
  }
}