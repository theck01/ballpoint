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
  static let kCanvasScreenSeparation: CGFloat = 12

  /// The size of the drawing, in points.
  static let kDrawingSize = CGSize(
      width: UIScreen.mainScreen().bounds.size.width -
          2 * Constants.kCanvasScreenSeparation,
      height: UIScreen.mainScreen().bounds.size.height -
          2 * Constants.kCanvasScreenSeparation)

  /// The duration of the view controller appearance animation.
  static let kViewControllerAppearDuration: NSTimeInterval = 0.6

  /// The minimum size of strokes.
  static let kMinimumStrokeWidth: CGFloat = 1

  /// The maximum size of strokes.
  static let kMaximumStrokeWidth: CGFloat = 30

  /// The brush used for the pen tool.
  static let kPenBrush = PipelineBrush()

  /// The brush used for the eraser tool.
  static let kEraserBrush = FountainBrush(minRadius: 10, maxRadius: 10)

  // The color ids for renderer colors uses in the application.
  static let kBallpointInkColorId: RendererColorId =
      "renderer-color-ballpoint-ink-color-id"
  static let kBallpointSurfaceColorId: RendererColorId =
      "renderer-color-ballpoint-surface-color-id"
}