//
//  DrawingModel.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// An in-memory model of the current drawing.
class DrawingModel {
  private var edits: [DrawingEdit] = []
  private(set) var modelSnapshot: UIImage = DrawingRenderer.renderStrokes(
      [], withinSize: Constants.kDrawingSize, onImage: nil)


  func addStroke(stroke: Stroke) {
    edits.append(DrawingEdit(type: .AddStroke, stroke: stroke))
    modelSnapshot = DrawingRenderer.renderStrokes(
        [stroke], withinSize: Constants.kDrawingSize, onImage: modelSnapshot)
  }

  
  func clearStrokes() {
    edits.append(DrawingEdit(type: .Clear, stroke: nil))
    modelSnapshot = DrawingRenderer.renderStrokes(
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
