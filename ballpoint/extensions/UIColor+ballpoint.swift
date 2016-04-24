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
  private static var _launchScreenBackgroundColor =
      UIColor(white: 0.938, alpha: 1)

  /// The backing instance for -ballpointInkColor
  private static var _ballpointInkColor =
      UIColor(red: 0.004, green: 0.083, blue: 0.116, alpha: 1)

  /// The backing instance for -ballpointSurfaceColor
  private static var _ballpointSurfaceColor = UIColor(white: 1, alpha: 1)

  /// The backing instance for -ballpointPressedButtonColor: UIColor?
  private static var _ballpointDepressedButtonColor =
      UIColor(white: 0.3, alpha: 0.3)


  // MARK: Custom colors

  static func launchScreenBackgroundColor() -> UIColor {
    return _launchScreenBackgroundColor
  }
  

  static func ballpointInkColor() -> UIColor {
    return _ballpointInkColor
  }

  static func ballpointSurfaceColor() -> UIColor {
    return _ballpointSurfaceColor
  }

  static func ballpointDepressedButtonColor() -> UIColor {
    return _ballpointDepressedButtonColor
  }


  // MARK: Helper methods

  func components() ->
      (red: CGFloat, blue: CGFloat, green: CGFloat, alpha: CGFloat) {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    return (red: r, green: g, blue: b, alpha: a)
  }
}