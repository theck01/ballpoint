//
//  UIDevice+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 2/10/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//

import UIKit



extension UIDevice {
  func deviceOrientationAngleOrDefault(defaultAngle: CGFloat) -> CGFloat {
    switch (orientation) {
      case UIDeviceOrientation.Portrait:
        return 0
      case UIDeviceOrientation.PortraitUpsideDown:
        return CGFloat(M_PI)
      case UIDeviceOrientation.LandscapeLeft:
        return CGFloat(3 * M_PI_2)
      case UIDeviceOrientation.LandscapeRight:
        return CGFloat(M_PI_2)
      default:
        return defaultAngle
    }
  }
}
