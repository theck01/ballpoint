//
//  DrawingUpdater.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/3/15.
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


class DrawingUpdater {
  private var drawingUpdateListeners: [DrawingUpdateListener] = []

  
  /// The snapshot of the updater's drawing.
  var drawingSnapshot: UIImage = DrawingRenderer.kEmptyRenderedDrawing {
    didSet {
      for listener in drawingUpdateListeners {
        listener.drawingSnapshotUpdated(drawingSnapshot)
      }
    }
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
}