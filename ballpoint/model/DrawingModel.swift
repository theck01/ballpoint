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
    case AddStrokes, Clear
  }

  let type: EditType
  let strokes: [Stroke]
}



/// Structure for a change to the snapshot of a drawing model.
struct DrawingModelSnapshotDiff {
  enum DiffType {
    case AddedStrokes, RemovedStrokes
  }

  let type: DiffType
  let strokes: [Stroke]
}



/// An in-memory model of the current drawing.
class DrawingModel: RendererColorPaletteUpdateListener {
  private(set) var drawingSnapshot: UIImage =
      DrawingRenderer.kEmptyRenderedDrawing
  private(set) var strokesInSnapshot: [Stroke] = []

  private let renderer: DrawingRenderer

  private var edits: [DrawingModelEdit] = []
  private var redoStack: [DrawingModelEdit] = []


  init (renderer: DrawingRenderer) {
    self.renderer = renderer
    RendererColorPalette.defaultPalette.registerColorPaletteUpdateListener(self)
  }

  
  /**
   - parameter edit: The edit to apply to the model.

   - returns: The change in strokes included in the drawing snapshot.
   */
  func applyEdit(edit: DrawingModelEdit) -> DrawingModelSnapshotDiff {
    edits.append(edit)
    redoStack = []
    let addedStrokes = applyEdits([edit], toSnapshot: drawingSnapshot)

    switch edit.type {
    case .AddStrokes:
      strokesInSnapshot += addedStrokes
      return DrawingModelSnapshotDiff(
          type: .AddedStrokes, strokes: addedStrokes)
    case .Clear:
      let diff = DrawingModelSnapshotDiff(
          type: .RemovedStrokes, strokes: strokesInSnapshot)
      strokesInSnapshot = []
      return diff
    }
  }


  /**
   Undoes the most recent model edit, if one exists.

   - returns: The edit undone on the model, if an edit could be undone.
   */
  func undo() -> DrawingModelSnapshotDiff? {
    if edits.isEmpty {
      return nil
    }
    let undoneEdit = edits.removeLast()
    redoStack.append(undoneEdit)
    strokesInSnapshot = applyEdits(edits, toSnapshot: nil)

    switch undoneEdit.type {
    case .AddStrokes:
      return DrawingModelSnapshotDiff(
          type: .RemovedStrokes, strokes: undoneEdit.strokes)
    case .Clear:
      let diff = DrawingModelSnapshotDiff(
          type: .AddedStrokes, strokes: strokesInSnapshot)
      return diff
    }
  }


  /**
   Redoes the most recently undone model edit, if one exists.

   - returns: The edit redone on the model, if an edit could be redone.
   */
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


  /// MARK: RendererColorPaletteUpdateListener methods

  func didUpdateRenderColorPalette(palette: RendererColorPalette) {
    applyEdits(edits, toSnapshot: nil)
  }


  /// MARK: Helper methods.

  /**
   Applys the edits to the drawing snapshot and updates the snapshot and array
   of strokes contained within the snapshot.

   - parameter edits: The edits to apply to the snapshot.
  
   - returns: The strokes added to the snapshot by applying the edits.
   */
  private func applyEdits(
      edits: [DrawingModelEdit], toSnapshot snapshot: UIImage?) -> [Stroke] {
    var baseSnapshotForRender: UIImage? = snapshot
    var strokesToRender: [Stroke] = []

    for e in edits {
      switch e.type {
      case .AddStrokes:
        strokesToRender += e.strokes
      case .Clear:
        strokesToRender = []
        baseSnapshotForRender = nil
      }
    }

    drawingSnapshot = renderer.renderStrokes(
        strokesToRender, onImage: baseSnapshotForRender)
    return strokesToRender
  }
}
