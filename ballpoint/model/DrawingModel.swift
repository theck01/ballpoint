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
  private let renderer: DrawingRenderer

  private var edits: [DrawingEdit] = []
  private var redoStack: [DrawingEdit] = []


  init (renderer: DrawingRenderer) {
    self.renderer = renderer
    super.init()
  }
  

  func addStroke(stroke: Stroke) {
    let addEdit = DrawingEdit(type: .AddStroke, stroke: stroke)
    edits.append(addEdit)
    redoStack = []
    applyEdits([addEdit], toSnapshot: drawingSnapshot)
  }

  
  func clearStrokes() {
    let clearEdit = DrawingEdit(type: .Clear, stroke: nil)
    edits.append(clearEdit)
    redoStack = []
    applyEdits([clearEdit], toSnapshot: drawingSnapshot)
  }


  func undo() {
    if edits.isEmpty {
      return
    }

    redoStack.append(edits.removeLast())
    applyEdits(edits, toSnapshot: nil)
  }


  func redo() {
    if redoStack.isEmpty {
      return
    }

    let redoEdit = redoStack.removeLast()
    edits.append(redoEdit)
    applyEdits([redoEdit], toSnapshot: drawingSnapshot)
  }


  /**
   :param: edits The edits to apply to the snapshot.
   */
  private func applyEdits(edits: [DrawingEdit], toSnapshot snapshot: UIImage?) {
    var baseSnapshotForRender: UIImage? = snapshot
    var strokesToRender: [Stroke] = []

    for e in edits {
      switch e.type {
      case .AddStroke:
        strokesToRender.append(e.stroke!)
      case .Clear:
        strokesToRender = []
        baseSnapshotForRender = nil
      }
    }

    drawingSnapshot = renderer.renderStrokes(
        strokesToRender, onImage: baseSnapshotForRender)
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
