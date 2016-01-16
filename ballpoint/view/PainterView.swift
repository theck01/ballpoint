//
//  PainterOverlayView.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/4/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



protocol PainterTouchDelegate {
  /**
   Informs the delegate that touches are actively painting.
   */
  func painterTouchesActive()

  /**
   Informs the delegate that no touches are actively painting.
   */
  func painterTouchesAbsent()
}



/// View that transforms user interaction events into drawing and application
/// actions.
class PainterView: UIView {

  /// A tuple containing all information required to process pending strokes.
  private struct RenderingStrokeTuple {
    /// The raw address of the UITouch object used to generate the stroke.
    let touchPointerId: UnsafePointer<Void>

    /// The underlying stroke object.
    let stroke: MutableStroke
  }

  /// The size factor to supply when 3D Touch is not available:
  /// 1 (average touch force) / 6.667 (maximum touch force)
  private static let kDefaultSizeFactor: CGFloat = 0.15

  /// The brush used to create strokes on the canvas.
  var brush: Brush
  
  /// The color of the strokes to paint.
  var paintColor: RendererColor
  
  var drawingInteractionDelegate: DrawingInteractionDelegate?

  var pendingStrokeRenderer: StrokeRenderer?

  var painterTouchDelegate: PainterTouchDelegate?

  /// An array of touch locations and pending strokes that last were updated to
  /// that location.
  private var pendingStrokeTuples: [RenderingStrokeTuple] = [] {
    didSet {
      if pendingStrokeTuples.count > 0 && oldValue.count == 0 {
        painterTouchDelegate?.painterTouchesActive()
      } else if pendingStrokeTuples.count == 0 && oldValue.count > 0 {
        painterTouchDelegate?.painterTouchesAbsent()
      }
    }
  }

  private var pendingStrokes: [MutableStroke] {
    return pendingStrokeTuples.map { $0.stroke }
  }


  /**
   Initializes the painter with the given brush, canvas, and paint color. The
   frame of the painter is set to the frame of the canvas.

   - parameter brush: The initial brush used to create strokes.
   - parameter paintColor: The initial color of strokes to generate.
   */
  init(brush: Brush, paintColor: RendererColor, frame: CGRect = CGRectZero) {
    self.brush = brush
    self.paintColor = paintColor

    super.init(frame: frame)

    multipleTouchEnabled = true
  }


  func createStrokePointFromTouch(touch: UITouch) -> StrokePoint {
    if #available(iOS 9.0, *) {
      if (traitCollection.forceTouchCapability ==
          UIForceTouchCapability.Available) {
        let sizeFactor = touch.force / touch.maximumPossibleForce
        return StrokePoint(
            location: touch.locationInView(self), sizeFactor: sizeFactor)
      }
    }
    return StrokePoint(
        location: touch.locationInView(self),
        sizeFactor: PainterView.kDefaultSizeFactor)
  }


  /// MARK: Touch event handlers.
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let stroke = MutableStroke(
          color: paintColor, brush: brush,
          minimumWidth: Constants.kMinimumStrokeWidth,
          maximumWidth: Constants.kMaximumStrokeWidth)
      stroke.appendPoint(createStrokePointFromTouch(touch))
      pendingStrokeTuples.append(RenderingStrokeTuple(
          touchPointerId: unsafeAddressOf(touch), stroke: stroke))
    }

    self.pendingStrokeRenderer?.renderStrokes(pendingStrokes)
  }
  
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let touchPointerId = unsafeAddressOf(touch)

      // Update the location-stroke pairs, updating the pair associated with
      // the given touch and extending the stroke to the new touch location.
      for t in pendingStrokeTuples {
        if t.touchPointerId == touchPointerId {
          t.stroke.appendPoint(createStrokePointFromTouch(touch))
        }
      }
    }

    self.pendingStrokeRenderer?.renderStrokes(pendingStrokes)
  }
  
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let tupleCountPriorToTouchEnd = pendingStrokeTuples.count
    var activeCompletedStrokes: [Stroke] = []
    
    for touch in touches {
      let touchPointerId = unsafeAddressOf(touch)

      // Update the location stroke pairs, droping pairs associated with the
      // touch that has ended.
      pendingStrokeTuples = pendingStrokeTuples.filter {
        // If the pending stroke is not associated with the end location then
        // do not end the stroke.
        if ($0.touchPointerId != touchPointerId) {
          return true
        }

        // If the touch ended at a different location than the previous location
        // then append the final location to the stroke.
        let location = touch.locationInView(self)
        if !(location =~= touch.previousLocationInView(self)) {
          $0.stroke.appendPoint(createStrokePointFromTouch(touch))
        }

        activeCompletedStrokes.append($0.stroke)
        return false
      }
    }

    pendingStrokeRenderer?.renderStrokes(pendingStrokes)
    drawingInteractionDelegate?.completeStrokes(activeCompletedStrokes)

    assert(
        tupleCountPriorToTouchEnd - touches.count ==
            pendingStrokeTuples.count,
        "A different number of strokes were ended than touches")
  }
  
  
  override func touchesCancelled(
      touches: Set<UITouch>?, withEvent event: UIEvent?) {
    /// Clear the strokes cancelled due to touch cancellation rather than just
    /// cancelling, as these strokes will never be ended by -touchesEnded.
    pendingStrokeTuples = []
    pendingStrokeRenderer?.renderStrokes(pendingStrokes)
  }


  /// MARK: Motion event handlers.

  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if motion == UIEventSubtype.MotionShake {
      drawingInteractionDelegate?.clearDrawing()
    }
  }


  /// MARK: UIResponder method overrides.

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
