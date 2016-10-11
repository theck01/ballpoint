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
  
  var viewDelegate: DrawingControllerViewDelegate?

  /// The current tool being used within the application.
  fileprivate var currentTool: EditingTool = .pen {
    didSet {
      switch (currentTool) {
      case .pen:
        viewDelegate?.painterView.brush = Constants.kPenBrush
        viewDelegate?.painterView.paintColor =
            RendererColorPalette.defaultPalette[Constants.kBallpointInkColorId]

        RendererColorPalette.defaultPalette.updatePalette([
          Constants.kBallpointInkColorId: UIColor.ballpointInkColor(),
          Constants.kBallpointSurfaceColorId: UIColor.ballpointSurfaceColor()
        ])

      case .eraser:
        viewDelegate?.painterView.brush = Constants.kEraserBrush
        viewDelegate?.painterView.paintColor =
            RendererColorPalette.defaultPalette[
                Constants.kBallpointSurfaceColorId]

        RendererColorPalette.defaultPalette.updatePalette([
          Constants.kBallpointInkColorId: UIColor.ballpointSurfaceColor(),
          Constants.kBallpointSurfaceColorId: UIColor.ballpointInkColor()
        ])
      }
    }
  }


  init(model: DrawingModel) {
    self.model = model
  }


  // MARK: DrawingInteractionDelegate methods.

  func completeStrokes(_ strokes: [Stroke]) {
    let edit = DrawingModelEdit(
        type: DrawingModelEdit.EditType.addStrokes, strokes: strokes)
    model.applyEdit(edit)
    viewDelegate?.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func clearDrawing() {
    let edit = DrawingModelEdit(
        type: DrawingModelEdit.EditType.clear, strokes: [])
    model.applyEdit(edit)
    viewDelegate?.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func toggleTool() {
    currentTool = currentTool.toggle()

    // Update the view controller's drawing snapshot after updating the current
    // tool, ensuring that the view controller gets a snapshot with the
    // appropriate color scheme.
    viewDelegate?.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func undo() {
    model.undo()
    viewDelegate?.updateDrawingSnapshot(model.drawingSnapshot)
  }


  func redo() {
    model.redo()
    viewDelegate?.updateDrawingSnapshot(model.drawingSnapshot)
  }
}
