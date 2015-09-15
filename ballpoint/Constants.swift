//
//  Constants.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/26/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class Constants {
  /// The size of the buttons within the UI.
  static let kButtonSize: CGFloat = 44

  /// The minimum separation between the canvas and the screen edge.
  static let kMinimumCanvasScreenSeparation: CGFloat = 8

  /// The size of the drawing, in points.
  static let kDrawingSize = CGSize(
      width: UIScreen.mainScreen().bounds.size.width -
          2 * Constants.kMinimumCanvasScreenSeparation,
      height: UIScreen.mainScreen().bounds.size.height -
          2 * Constants.kMinimumCanvasScreenSeparation -
          Constants.kButtonSize)

  /// The default duration of animations.
  static let kDefaultAnimationDuration: NSTimeInterval = 0.3

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