//
//  DrawingController.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// A controller responsible for transforming interactions into model edits and
/// notifying listeners when the drawing updates.
class DrawingController: DrawingInteractionDelegate {
  private enum EditingTool {
    case Pen
    case Eraser

    func toggle() -> EditingTool {
      return self == .Pen ? .Eraser : .Pen
    }
  }

  private let model: DrawingModel
  private let viewController: DrawingViewController

  /// The current tool being used within the application.
  private var currentTool: EditingTool = .Pen {
    didSet {
      switch (currentTool) {
      case .Pen:
        viewController.painterView.brush = CircularBrush(
            radius: Constants.kPenBrushSize)
        viewController.painterView.paintColor =
            RendererColorPalette.defaultPalette[Constants.kBallpointInkColorId]

        RendererColorPalette.defaultPalette.updatePalette([
          Constants.kBallpointInkColorId: UIColor.ballpointInkColor(),
          Constants.kBallpointSurfaceColorId: UIColor.ballpointSurfaceColor()
        ])

      case .Eraser:
        viewController.painterView.brush = CircularBrush(
            radius: Constants.kEraserBrushSize)
        viewController.painterView.paintColor =
            RendererColorPalette.defaultPalette[
                Constants.kBallpointSurfaceColorId]

        RendererColorPalette.defaultPalette.updatePalette([
          Constants.kBallpointInkColorId: UIColor.ballpointSurfaceColor(),
          Constants.kBallpointSurfaceColorId: UIColor.ballpointInkColor()
        ])
      }
    }
  }

  init(model: DrawingModel, viewController: DrawingViewController) {
    self.model = model
    self.viewController = viewController
  }


  /// MARK: DrawingInteractionDelegate methods.

  func completeStrokes(strokes: [Stroke]) {
    model.addStrokes(strokes)
  }


  func clearDrawing() {
    model.clearStrokes()
  }


  func toggleTool() {
    currentTool = currentTool.toggle()
  }


  func undo() {
    model.undo()
  }


  func redo() {
    model.redo()
  }
}