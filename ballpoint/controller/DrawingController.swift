//
//  DrawingController.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// A protocol for an listener that should be notified each time that the
/// drawing snapshot changes.
protocol DrawingUpdateListener {
  /**
   Informs the listener that a new snapshot has been made available.
   
   :param: The new snapshot of the drawing.
   */
  func drawingSnapshotUpdated(snapshot: UIImage)
}



/// A controller responsible for transforming interactions into model edits and
/// notifying listeners when the drawing updates.
class DrawingController: DrawingInteractionDelegate {
  let model: DrawingModel

  private var drawingUpdateListeners: [DrawingUpdateListener] = []

  private var pendingStrokeIdMap: [StrokeId: Stroke] = [:]

  private var drawingSnapshot: UIImage = DrawingRenderer.renderStrokes(
      [], withinSize: Constants.kDrawingSize, onImage: nil) {
    didSet {
      for listener in drawingUpdateListeners {
        listener.drawingSnapshotUpdated(drawingSnapshot)
      }
    }
  }


  init(model: DrawingModel) {
    self.model = model
  }


  /**
   Registers a new listener for drawing updates and immediately supplies the
   listener with the current drawing representation.

   :param: listener
   */
  func registerDrawingUpdateListener(listener: DrawingUpdateListener) {
    drawingUpdateListeners.append(listener)
    listener.drawingSnapshotUpdated(drawingSnapshot)
  }


  /// MARK: DrawingInteractionDelegate methods.

  func updatePendingStroke(stroke: Stroke) {
    pendingStrokeIdMap[stroke.id] = stroke
    updateDrawingSnapshot()
  }


  func cancelPendingStrokes() {
    pendingStrokeIdMap = [:]
    updateDrawingSnapshot()
  }


  func completeStroke(stroke: Stroke) {
    assert(
        pendingStrokeIdMap[stroke.id] != nil,
        "Cannot complete a stroke that was never pending.")
    model.addStroke(stroke)
    pendingStrokeIdMap[stroke.id] = nil
    updateDrawingSnapshot()
  }


  func clearDrawing() {
    model.clearStrokes()
    updateDrawingSnapshot()
  }


  func toggleTool() {
    println("Tool toggled!")
  }


  /// MARK: Private methods

  func updateDrawingSnapshot() {
    if pendingStrokeIdMap.isEmpty {
      drawingSnapshot =  model.modelSnapshot
    } else {
      drawingSnapshot = DrawingRenderer.renderStrokes(
          [Stroke](pendingStrokeIdMap.values),
          withinSize: Constants.kDrawingSize, onImage: model.modelSnapshot)
    }
  }
}