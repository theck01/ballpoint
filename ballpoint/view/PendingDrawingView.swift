//
//  PendingDrawingView.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit

class PendingDrawingView: UIView, PendingStrokeDelegate {
  private var pendingStrokeIdMap: [StrokeId: MutableStroke] = [:]

  private var pendingBoundingBox: CGRect {
    return [MutableStroke](pendingStrokeIdMap.values).reduce(CGRectNull) {
        (boundingRect: CGRect, stroke: MutableStroke) in
      return CGRectUnion(boundingRect, stroke.dirtyBoundingRect)
    }
  }


  func updatePendingStroke(stroke: MutableStroke) {
    pendingStrokeIdMap[stroke.id] = stroke
    setNeedsDisplayInRect(pendingBoundingBox)
  }


  func completePendingStroke(stroke: Stroke) {
    assert(
        pendingStrokeIdMap[stroke.id] != nil,
        "Cannot complete a stroke that was never pending.")
    setNeedsDisplayInRect(stroke.boundingRect)
    pendingStrokeIdMap[stroke.id] = nil
  }


  func cancelPendingStrokes() {
    pendingStrokeIdMap = [:]
    setNeedsDisplay()
  }


  override func drawRect(rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()

    for s in [MutableStroke](pendingStrokeIdMap.values) {
      if CGRectIntersectsRect(rect, s.boundingRect) {
        s.paintOn(context)
      }
    }
  }
}
