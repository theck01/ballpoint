//
//  UIView+ballpoint.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/26/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import UIKit



extension UIView {
  /**
  Animate the canvas's shadow appearance to the given opacity, radius, and
  offset.

  - parameter shadowOpacity:
  - parameter shadowRadius:
  - parameter shadowYOffset:
  */
  func animateShadowAppearanceWithDuration(
      duration: NSTimeInterval, shadowOpacity: CGFloat, shadowRadius: CGFloat,
      shadowYOffset: CGFloat) {
    let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
    shadowOpacityAnimation.fromValue = NSNumber(
        double: Double(layer.shadowOpacity))
    shadowOpacityAnimation.toValue = NSNumber(double: Double(shadowOpacity))
    shadowOpacityAnimation.duration = duration
    shadowOpacityAnimation.fillMode =
        Float(shadowOpacity) > layer.shadowOpacity ?
            kCAFillModeForwards :
            kCAFillModeBackwards
    layer.addAnimation(shadowOpacityAnimation, forKey: "shadowOpacity")
    layer.shadowOpacity = Float(shadowOpacity)

    let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
    shadowRadiusAnimation.fromValue = NSNumber(
        double: Double(layer.shadowRadius))
    shadowRadiusAnimation.toValue = NSNumber(double: Double(shadowRadius))
    shadowRadiusAnimation.duration = duration
    shadowRadiusAnimation.fillMode = shadowRadius > layer.shadowRadius ?
        kCAFillModeForwards :
        kCAFillModeBackwards
    layer.addAnimation(shadowRadiusAnimation, forKey: "shadowRadius")
    layer.shadowRadius = shadowRadius

    let endShadowOffset = CGSize(width: 0, height: shadowYOffset)
    let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
    shadowOffsetAnimation.fromValue = NSValue(CGSize: layer.shadowOffset)
    shadowOffsetAnimation.toValue = NSValue(CGSize: endShadowOffset)
    shadowOffsetAnimation.duration = duration
    shadowRadiusAnimation.fillMode = shadowYOffset > layer.shadowOffset.height ?
        kCAFillModeForwards :
        kCAFillModeBackwards
    layer.addAnimation(shadowOffsetAnimation, forKey: "shadowOffset")
    layer.shadowOffset = endShadowOffset
  }
}
