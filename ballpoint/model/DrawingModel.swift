//
//  DrawingModel.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// An in-memory model of the current drawing.
class DrawingModel: DrawingUpdater {
  private var edits: [DrawingEdit] = []


  func addStroke(stroke: Stroke) {
    edits.append(DrawingEdit(type: .AddStroke, stroke: stroke))
    drawingSnapshot = DrawingRenderer.renderStrokes(
        [stroke], withinSize: Constants.kDrawingSize, onImage: drawingSnapshot)
  }

  
  func clearStrokes() {
    edits.append(DrawingEdit(type: .Clear, stroke: nil))
    drawingSnapshot = DrawingRenderer.renderStrokes(
        [], withinSize: Constants.kDrawingSize, onImage: nil)
  }
}


private struct DrawingEdit {
  private enum Type {
    case AddStroke
    case Clear
  }

  let type: Type
  let stroke: Stroke?
}
