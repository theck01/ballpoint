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


  func updatePendingStrokes(strokes: [MutableStroke]) {
    for s in strokes {
      pendingStrokeIdMap[s.id] = s
    }
    setNeedsDisplayInRect(pendingBoundingBox)
  }


  func completePendingStrokes(strokes: [Stroke]) {
    var boundingRect: CGRect = CGRectNull
    for s in strokes {
      assert(
          pendingStrokeIdMap[s.id] != nil,
          "Cannot complete a stroke that was never pending.")
      pendingStrokeIdMap[s.id] = nil
      boundingRect = CGRectUnion(s.boundingRect, boundingRect)
    }
    setNeedsDisplayInRect(boundingRect)
  }


  func cancelPendingStrokes() {
    if !pendingStrokeIdMap.isEmpty {
      let boundingRect = [MutableStroke](pendingStrokeIdMap.values).reduce(
          CGRectNull) {
        return CGRectUnion($0, $1.boundingRect)
      }
      pendingStrokeIdMap = [:]
      setNeedsDisplayInRect(boundingRect)
    }
  }


  override func drawRect(rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      for s in [MutableStroke](pendingStrokeIdMap.values) {
        if CGRectIntersectsRect(rect, s.boundingRect) {
          s.paintOn(context)
        }
      }
    }
  }
}
