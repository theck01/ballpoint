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

  /// The map of strokes that require drawing.
  private var pendingStrokes: (ids: Set<StrokeId>, strokes: [Stroke]) =
  (ids: Set(), strokes: [])

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

  /// The current graphics context. Only valid during a -drawRect call, cached
  /// for speed.
  private var context: CGContext!


  init(frame: CGRect, editable: Bool = true) {
    let bounds = CGRect(origin: CGPointZero, size: frame.size)
    
    photographer = CanvasPhotographer(imageSize: bounds.size)
    
    painter = editable ?
        PainterView(
            brush: DrawingView.kDefaultBrush,
            paintColor: DrawingView.kDefaultPaintColor, frame: bounds) :
        nil
    painter?.backgroundColor = UIColor.clearColor()
    
    super.init(frame: frame)

    backgroundColor = UIColor.clearColor()
    
    painter?.delegate = self
    
    if let p = painter {
      addSubview(p)
    }
  }


  func clearStrokes() {
    clearPendingStrokes()
    photographer.clearSnapshot()
  }


  /// MARK: PainterViewDelegate methods

  func pendingStrokeUpdated(stroke: Stroke) {
    if let p = painter {
      for s in p.pendingStrokes {
        addPendingStroke(s)
      }
    }
  }


  func pendingStrokesCancelled(strokes: [Stroke]) {
    clearPendingStrokes()
  }

  
  func strokeCompleted(stroke: Stroke) {
    photographer.addStrokeToSnapshot(stroke)
  }


  /// MARK: UIView method overrides.

  override func drawRect(rect: CGRect) {
    context = UIGraphicsGetCurrentContext()

    // Draw snapshot on the context, using -drawInRect to ensure that the
    // image is oriented properly within the context.
    photographer.snapshot.drawInRect(
        CGRect(origin: CGPointZero, size: bounds.size))

    if pendingStrokes.strokes.count > 0 {
        for s in pendingStrokes.strokes {
          s.paintOn(context)
        }
        pendingStrokes = (ids: Set(), strokes: [])
    }

    context = nil
  }


  /// MARK: Private methods.

  /**
   Adds the given stroke as pending within the canvas view. Does nothing if the
   given stroke is already pending within the view.

   :param: stroke
   */
  private func addPendingStroke(stroke: Stroke) {
    if !pendingStrokes.ids.contains(stroke.id) {
      pendingStrokes.ids.insert(stroke.id)
      pendingStrokes.strokes.append(stroke)

      setNeedsDisplay()
    }
  }


  /**
   Clears the view of pending strokes and redraws the screen.
   */
  private func clearPendingStrokes() {
    pendingStrokes = (ids: [], strokes: [])
    setNeedsDisplay()
  }


  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
