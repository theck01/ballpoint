//
//  DrawingView.swift
//  inkwell
//
//  Created by Tyler Heck on 8/15/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit


/// A view that manages displaying a drawing and optionally handling gesture
/// input that updates the drawing.
class DrawingView: UIView, PainterViewDelegate {
  // The default values for the brush and paint color used for editable
  //drawings.
  static let kDefaultBrush = CircularBrush(radius: 2)
  static let kDefaultPaintColor = UIColor.blackColor()
  
  /// The image view that backs the canvas, providing a persistant view of all
  /// completed strokes.
  private var completedCanvas: UIImageView
  
  /// The canvas upon which pending strokes are painted.
  private var pendingCanvas: PendingCanvasView
  
  /// The photographer that converts drawings to images.
  private var photographer: CanvasPhotographer
  
  /// The optional painter view, which if present converts user touches to
  /// stroke objects.
  private var painter: PainterView? {
    didSet {
      oldValue?.delegate = nil
      if let ov = oldValue {
        ov.removeFromSuperview()
      }
      
      painter?.delegate = self
      if let p = painter {
        p.frame = bounds
        addSubview(p)
      }
    }
  }
  
  
  init(frame: CGRect, editable: Bool = true) {
    let bounds = CGRect(origin: CGPointZero, size: frame.size)
    
    pendingCanvas = PendingCanvasView(frame: bounds)
    pendingCanvas.backgroundColor = UIColor.clearColor()
    
    photographer = CanvasPhotographer(imageSize: bounds.size)
    
    completedCanvas = UIImageView(image: photographer.snapshot)
    completedCanvas.backgroundColor = UIColor.clearColor()
    
    painter = editable ?
        PainterView(
            brush: DrawingView.kDefaultBrush,
            paintColor: DrawingView.kDefaultPaintColor, frame: bounds) :
        nil
    painter?.backgroundColor = UIColor.clearColor()
    
    super.init(frame: frame)
    
    painter?.delegate = self
    
    addSubview(completedCanvas)
    addSubview(pendingCanvas)
    if let p = painter {
      addSubview(p)
    }
  }

  
  func pendingStrokeUpdated(stroke: Stroke) {
    if let p = painter {
      for s in p.pendingStrokes {
        pendingCanvas.addPendingStroke(s)
      }
    }
  }
  
  
  func strokeCompleted(stroke: Stroke) {
    photographer.addStrokeToSnapshot(stroke)
    completedCanvas.image = photographer.snapshot
  }
  

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
