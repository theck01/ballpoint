//
//  Constants.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/26/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class Constants {
  /// The size of the drawing, in points.
  static let kDrawingSize: CGSize = UIScreen.mainScreen().bounds.size

  /// The duration of the fade in animation on app launch.
  static let kAppLaunchedAnimationDuration: NSTimeInterval = 0.1

  /// The size of the pen brush.
  static let kPenBrushSize: CGFloat = 2.0

  /// The size of the eraser brush.
  static let kEraserBrushSize: CGFloat = 10.0

  // The color ids for renderer colors uses in the application.
  static let kBallpointInkColorId: RendererColorId =
      "renderer-color-ballpoint-ink-color-id"
  static let kBallpointSurfaceColorId: RendererColorId =
      "renderer-color-ballpoint-surface-color-id"
}