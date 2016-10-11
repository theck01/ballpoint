//
//  UIDevice+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 2/10/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//

import UIKit



extension UIDevice {
  @nonobjc static let kPortraitAngle: CGFloat = 0
  @nonobjc static let kLandscapeRightAngle = CGFloat(M_PI_2)
  @nonobjc static let kUpsideDownPortraitAngle = CGFloat(M_PI)
  @nonobjc static let kLandscapeLeftAngle = CGFloat(3 * M_PI_2)

  func deviceOrientationAngleOrDefault(_ defaultAngle: CGFloat) -> CGFloat {
    switch (orientation) {
      case UIDeviceOrientation.portrait:
        return UIDevice.kPortraitAngle
      case UIDeviceOrientation.portraitUpsideDown:
        return UIDevice.kUpsideDownPortraitAngle
      case UIDeviceOrientation.landscapeLeft:
        return UIDevice.kLandscapeLeftAngle
      case UIDeviceOrientation.landscapeRight:
        return UIDevice.kLandscapeRightAngle
      default:
        return defaultAngle
    }
  }
}
