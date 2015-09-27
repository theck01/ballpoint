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
    let edit = DrawingModelEdit(
        type: DrawingModelEdit.EditType.AddStrokes, strokes: strokes)
    model.applyEdit(edit)
    viewController.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func clearDrawing() {
    let edit = DrawingModelEdit(
        type: DrawingModelEdit.EditType.Clear, strokes: [])
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
    if let diff = model.undo() {
      updateViewControllerWithModelDiff(diff)
    }
  }


  func redo() {
    if let diff = model.redo() {
      updateViewControllerWithModelDiff(diff)
    }
  }


  /// MARK: Helper methods.

  func updateViewControllerWithModelDiff(diff: DrawingModelSnapshotDiff) {
    switch diff.type {
    case DrawingModelSnapshotDiff.DiffType.AddedStrokes:
      viewController.updateDrawingSnapshot(
          model.drawingSnapshot, addedStrokes: diff.strokes)
    case DrawingModelSnapshotDiff.DiffType.RemovedStrokes:
      viewController.updateDrawingSnapshot(
          model.drawingSnapshot, removedStrokes: diff.strokes)
    }
  }
}