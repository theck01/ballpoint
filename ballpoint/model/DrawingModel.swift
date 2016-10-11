//
//  DrawingModel.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit


/// Structure for an edit to the drawing model.
struct DrawingModelEdit {
  enum EditType {
    case addStrokes, clear
  }

  let type: EditType
  let strokes: [Stroke]
}



/// Structure for a change to the snapshot of a drawing model.
struct DrawingModelSnapshotDiff {
  enum DiffType {
    case addedStrokes, removedStrokes
  }

  let type: DiffType
  let strokes: [Stroke]
}



/// An in-memory model of the current drawing.
class DrawingModel: RendererColorPaletteUpdateListener {
  fileprivate(set) var drawingSnapshot: UIImage
  fileprivate(set) var strokesInSnapshot: [Stroke] = []

  fileprivate let renderer: DrawingRenderer

  fileprivate var edits: [DrawingModelEdit] = []
  fileprivate var redoStack: [DrawingModelEdit] = []


  init (renderer: DrawingRenderer) {
    self.renderer = renderer
    self.drawingSnapshot = renderer.emptyDrawing
    RendererColorPalette.defaultPalette.registerColorPaletteUpdateListener(self)
  }

  
  /**
   - parameter edit: The edit to apply to the model.

   - returns: The change in strokes included in the drawing snapshot.
   */
  @discardableResult
  func applyEdit(_ edit: DrawingModelEdit) -> DrawingModelSnapshotDiff? {
    // Do not apply multiple clear edits in a row.
    if edit.type == .clear && edits.last?.type == .clear {
      return nil
    }

    edits.append(edit)
    redoStack = []
    let addedStrokes = applyEdits([edit], toSnapshot: drawingSnapshot)

    switch edit.type {
    case .addStrokes:
      strokesInSnapshot += addedStrokes
      return DrawingModelSnapshotDiff(
          type: .addedStrokes, strokes: addedStrokes)
    case .clear:
      let diff = DrawingModelSnapshotDiff(
          type: .removedStrokes, strokes: strokesInSnapshot)
      strokesInSnapshot = []
      return diff
    }
  }


  /**
   Undoes the most recent model edit, if one exists.

   - returns: The edit undone on the model, if an edit could be undone.
   */
  @discardableResult
  func undo() -> DrawingModelSnapshotDiff? {
    if edits.isEmpty {
      return nil
    }
    let undoneEdit = edits.removeLast()
    redoStack.append(undoneEdit)
    strokesInSnapshot = applyEdits(edits, toSnapshot: nil)

    switch undoneEdit.type {
    case .addStrokes:
      return DrawingModelSnapshotDiff(
          type: .removedStrokes, strokes: undoneEdit.strokes)
    case .clear:
      let diff = DrawingModelSnapshotDiff(
          type: .addedStrokes, strokes: strokesInSnapshot)
      return diff
    }
  }


  /**
   Redoes the most recently undone model edit, if one exists.

   - returns: The edit redone on the model, if an edit could be redone.
   */
  @discardableResult
  func redo() -> DrawingModelSnapshotDiff? {
    if redoStack.isEmpty {
      return nil
    }
    let redoneEdit = redoStack.removeLast()
    let preservedRedoStack = redoStack
    let diff = applyEdit(redoneEdit)
    redoStack = preservedRedoStack
    return diff
  }


  // MARK: RendererColorPaletteUpdateListener methods

  func didUpdateRenderColorPalette(_ palette: RendererColorPalette) {
    applyEdits(edits, toSnapshot: nil)
  }


  // MARK: Helper methods.

  /**
   Applys the edits to the drawing snapshot and updates the snapshot and array
   of strokes contained within the snapshot.

   - parameter edits: The edits to apply to the snapshot.
  
   - returns: The strokes added to the snapshot by applying the edits.
   */
  @discardableResult
  fileprivate func applyEdits(
      _ edits: [DrawingModelEdit], toSnapshot snapshot: UIImage?) -> [Stroke] {
    var baseSnapshotForRender: UIImage? = snapshot
    var strokesToRender: [Stroke] = []

    for e in edits {
      switch e.type {
      case .addStrokes:
        strokesToRender += e.strokes
      case .clear:
        strokesToRender = []
        baseSnapshotForRender = nil
      }
    }

    drawingSnapshot = renderer.renderStrokes(
        strokesToRender, onImage: baseSnapshotForRender)
    return strokesToRender
  }
}
