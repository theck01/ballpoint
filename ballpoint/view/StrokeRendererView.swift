//
//  StrokeRenderer.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit

class StrokeRendererView: UIView, StrokeRenderer {
  private var strokesToRender: [Stroke] = []


  func renderStrokes(strokes: [Stroke]) {
    strokesToRender = strokes
    setNeedsDisplay()
  }


  override func drawRect(rect: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      for stroke in strokesToRender {
        stroke.paintOn(context)
      }
      strokesToRender = []
    }
  }
}
