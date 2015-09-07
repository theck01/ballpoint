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
  private let model: DrawingModel

  init(model: DrawingModel) {
    self.model = model
  }


  /// MARK: DrawingInteractionDelegate methods.

  func completeStrokes(strokes: [Stroke]) {
    model.addStrokes(strokes)
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