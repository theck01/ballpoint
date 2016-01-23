//
//  Constants.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/26/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class Constants {
  /// The minimum separation between the canvas and the screen edge.
  static let kCanvasMargin: CGFloat = 12

  /// The duration of the view controller appearance animation.
  static let kViewControllerAppearDuration: NSTimeInterval = 0.6

  /// The minimum size of strokes.
  static let kMinimumStrokeWidth: CGFloat = 1

  /// The maximum size of strokes.
  static let kMaximumStrokeWidth: CGFloat = 15

  /// The brush used for the pen tool.
  static let kPenBrush = PipelineBrush()

  /// The brush used for the eraser tool.
  static let kEraserBrush = PipelineBrush()

  // The color ids for renderer colors uses in the application.
  static let kBallpointInkColorId: RendererColorId =
      "renderer-color-ballpoint-ink-color-id"
  static let kBallpointSurfaceColorId: RendererColorId =
      "renderer-color-ballpoint-surface-color-id"
}