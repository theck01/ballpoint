//
//  DrawingModel.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// An in-memory model of the current drawing.
class DrawingModel: DrawingUpdater, RendererColorPaletteUpdateListener {
  private let renderer: DrawingRenderer

  private var edits: [DrawingEdit] = []
  private var redoStack: [DrawingEdit] = []


  init (renderer: DrawingRenderer) {
    self.renderer = renderer
    super.init()

    RendererColorPalette.defaultPalette.registerColorPaletteUpdateListener(self)
  }
  

  func addStrokes(strokes: [Stroke]) {
    let addEdit = DrawingEdit(type: .AddStrokes, strokes: strokes)
    edits.append(addEdit)
    redoStack = []
    applyEdits([addEdit], toSnapshot: drawingSnapshot)
  }

  
  func clearStrokes() {
    let clearEdit = DrawingEdit(type: .Clear, strokes: [])
    edits.append(clearEdit)
    redoStack = []
    applyEdits([clearEdit], toSnapshot: drawingSnapshot)
  }


  func undo() {
    if edits.isEmpty {
      return
    }

    renderer.incrementRevision()
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


  /// MARK: RendererColorPaletteUpdateListener methods

  func didUpdateRenderColorPalette(palette: RendererColorPalette) {
    applyEdits(edits, toSnapshot: nil)
  }


  /// MARK: Helper methods.

  /**
   - parameter edits: The edits to apply to the snapshot.
   */
  private func applyEdits(edits: [DrawingEdit], toSnapshot snapshot: UIImage?) {
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
  }
}


private struct DrawingEdit {
  private enum Type {
    case AddStrokes
    case Clear
  }

  let type: Type
  let strokes: [Stroke]
}
