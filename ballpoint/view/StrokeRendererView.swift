//
//  StrokeRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit

class StrokeRendererView: UIView, StrokeRenderer {
  fileprivate var strokesToRender: [Stroke] = []


  func renderStrokes(_ strokes: [Stroke]) {
    strokesToRender = strokes
    setNeedsDisplay()
  }


  override func draw(_ rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      for stroke in strokesToRender {
        if let renderedStroke = stroke.brush.render(stroke) {
          renderedStroke.paintOn(context)
        }
      }
      strokesToRender = []
    }
  }
}
