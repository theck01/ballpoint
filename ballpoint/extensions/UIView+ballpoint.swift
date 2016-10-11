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
      _ duration: TimeInterval, shadowOpacity: CGFloat, shadowRadius: CGFloat,
      shadowYOffset: CGFloat) {
    let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
    shadowOpacityAnimation.fromValue = NSNumber(value: Double(layer.shadowOpacity) as Double)
    shadowOpacityAnimation.toValue = NSNumber(value: Double(shadowOpacity) as Double)
    shadowOpacityAnimation.duration = duration
    shadowOpacityAnimation.fillMode =
        Float(shadowOpacity) > layer.shadowOpacity ?
            kCAFillModeForwards :
            kCAFillModeBackwards
    layer.add(shadowOpacityAnimation, forKey: "shadowOpacity")
    layer.shadowOpacity = Float(shadowOpacity)

    let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
    shadowRadiusAnimation.fromValue = NSNumber(value: Double(layer.shadowRadius) as Double)
    shadowRadiusAnimation.toValue = NSNumber(value: Double(shadowRadius) as Double)
    shadowRadiusAnimation.duration = duration
    shadowRadiusAnimation.fillMode = shadowRadius > layer.shadowRadius ?
        kCAFillModeForwards :
        kCAFillModeBackwards
    layer.add(shadowRadiusAnimation, forKey: "shadowRadius")
    layer.shadowRadius = shadowRadius

    let endShadowOffset = CGSize(width: 0, height: shadowYOffset)
    let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
    shadowOffsetAnimation.fromValue = NSValue(cgSize: layer.shadowOffset)
    shadowOffsetAnimation.toValue = NSValue(cgSize: endShadowOffset)
    shadowOffsetAnimation.duration = duration
    shadowRadiusAnimation.fillMode = shadowYOffset > layer.shadowOffset.height ?
        kCAFillModeForwards :
        kCAFillModeBackwards
    layer.add(shadowOffsetAnimation, forKey: "shadowOffset")
    layer.shadowOffset = endShadowOffset
  }
}
