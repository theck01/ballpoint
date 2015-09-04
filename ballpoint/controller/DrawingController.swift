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
class DrawingController: DrawingUpdater, DrawingUpdateListener,
    DrawingInteractionDelegate {
  let model: DrawingModel

  private var pendingStrokeIdMap: [StrokeId: Stroke] = [:]


  init(model: DrawingModel) {
    self.model = model
    super.init()
    
    model.registerDrawingUpdateListener(self)
  }


  /// MARK: DrawingUpdateListener methods.

  func drawingSnapshotUpdated(snapshot: UIImage) {
    if pendingStrokeIdMap.isEmpty {
      drawingSnapshot =  snapshot
    } else {
      drawingSnapshot = DrawingRenderer.renderStrokes(
          [Stroke](pendingStrokeIdMap.values),
          withinSize: Constants.kDrawingSize, onImage: snapshot)
    }
  }


  /// MARK: DrawingInteractionDelegate methods.

  func updatePendingStroke(stroke: Stroke) {
    pendingStrokeIdMap[stroke.id] = stroke
    drawingSnapshot = DrawingRenderer.renderStrokes(
        [Stroke](pendingStrokeIdMap.values),
        withinSize: Constants.kDrawingSize, onImage: model.drawingSnapshot)
  }


  func cancelPendingStrokes() {
    pendingStrokeIdMap = [:]
    drawingSnapshot = model.drawingSnapshot
  }


  func completeStroke(stroke: Stroke) {
    assert(
        pendingStrokeIdMap[stroke.id] != nil,
        "Cannot complete a stroke that was never pending.")
    model.addStroke(stroke)
    pendingStrokeIdMap[stroke.id] = nil
  }


  func clearDrawing() {
    model.clearStrokes()
  }


  func toggleTool() {
    println("Tool toggled!")
  }


  func undo() {
    model.undo()
  }


  func redo() {
    model.redo()
  }
}