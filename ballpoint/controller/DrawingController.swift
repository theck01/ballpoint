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
  fileprivate enum EditingTool {
    case pen
    case eraser

    func toggle() -> EditingTool {
      return self == .pen ? .eraser : .pen
    }
  }

  fileprivate let model: DrawingModel
  fileprivate let viewController: DrawingViewController

  /// The current tool being used within the application.
  fileprivate var currentTool: EditingTool = .pen {
    didSet {
      switch (currentTool) {
      case .pen:
        viewController.painterView.brush = Constants.kPenBrush
        viewController.painterView.paintColor =
            RendererColorPalette.defaultPalette[Constants.kBallpointInkColorId]

        RendererColorPalette.defaultPalette.updatePalette([
          Constants.kBallpointInkColorId: UIColor.ballpointInkColor(),
          Constants.kBallpointSurfaceColorId: UIColor.ballpointSurfaceColor()
        ])

      case .eraser:
        viewController.painterView.brush = Constants.kEraserBrush
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


  // MARK: DrawingInteractionDelegate methods.

  func completeStrokes(_ strokes: [Stroke]) {
    let edit = DrawingModelEdit(
        type: DrawingModelEdit.EditType.addStrokes, strokes: strokes)
    model.applyEdit(edit)
    viewController.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func clearDrawing() {
    let edit = DrawingModelEdit(
        type: DrawingModelEdit.EditType.clear, strokes: [])
    model.applyEdit(edit)
    viewController.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func toggleTool() {
    currentTool = currentTool.toggle()

    // Update the view controller's drawing snapshot after updating the current
    // tool, ensuring that the view controller gets a snapshot with the
    // appropriate color scheme.
    viewController.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func undo() {
    model.undo()
    viewController.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func redo() {
    model.redo()
    viewController.updateDrawingSnapshot(model.drawingSnapshot)
  }
}
