//
//  StrokeRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit

class StrokeRendererView: UIView {
  private var renderingStrokeIdMap: [StrokeId: MutableStroke] = [:]

  private var renderingBoundingBox: CGRect {
    return [MutableStroke](renderingStrokeIdMap.values).reduce(CGRectNull) {
        (boundingRect: CGRect, stroke: MutableStroke) in
      return CGRectUnion(boundingRect, stroke.dirtyBoundingRect)
    }
  }


  func updateRenderingStrokes(strokes: [MutableStroke]) {
    for s in strokes {
      renderingStrokeIdMap[s.id] = s
    }
    setNeedsDisplayInRect(renderingBoundingBox)
  }


  func completeRenderingStrokes(strokes: [Stroke]) {
    var boundingRect: CGRect = CGRectNull
    for s in strokes {
      assert(
          renderingStrokeIdMap[s.id] != nil,
          "Cannot complete a stroke that was never pending.")
      renderingStrokeIdMap[s.id] = nil
      boundingRect = CGRectUnion(s.boundingRect, boundingRect)
    }
    setNeedsDisplayInRect(boundingRect)
  }


  func cancelRenderingStrokes() {
    if !renderingStrokeIdMap.isEmpty {
      let boundingRect = [MutableStroke](renderingStrokeIdMap.values).reduce(
          CGRectNull) {
        return CGRectUnion($0, $1.boundingRect)
      }
      renderingStrokeIdMap = [:]
      setNeedsDisplayInRect(boundingRect)
    }
  }


  override func drawRect(rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      for s in [MutableStroke](renderingStrokeIdMap.values) {
        if CGRectIntersectsRect(rect, s.boundingRect) {
          s.paintOn(context)
        }
      }
    }
  }
}
