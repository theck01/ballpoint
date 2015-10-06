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

    /// Whether the pending stroke has been cancelled and is just being kept
    /// around for bookkeeping.
    let isCancelled: Bool

    /// The underlying stroke object.
    let stroke: MutableStroke
  }

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

  /// Whether the pending strokes should be rendered.
  private var shouldRenderPendingStrokes: Bool {
    return pendingStrokeTuples.count < 2 &&
        (!(pendingStrokeTuples.first?.isCancelled ?? false))
  }

  // The gesture recognizers that map to application actions.
  private let twoTouchTapRecognizer: UITapGestureRecognizer

  
  /**
   Initializes the painter with the given brush, canvas, and paint color. The
   frame of the painter is set to the frame of the canvas.

   - parameter brush: The initial brush used to create strokes.
   - parameter paintColor: The initial color of strokes to generate.
   */
  init(brush: Brush, paintColor: RendererColor, frame: CGRect = CGRectZero) {
    self.brush = brush
    self.paintColor = paintColor
    twoTouchTapRecognizer = UITapGestureRecognizer()

    super.init(frame: frame)

    multipleTouchEnabled = true

    twoTouchTapRecognizer.cancelsTouchesInView = false
    twoTouchTapRecognizer.delaysTouchesBegan = false
    twoTouchTapRecognizer.delaysTouchesEnded = false
    twoTouchTapRecognizer.numberOfTapsRequired = 1
    twoTouchTapRecognizer.numberOfTouchesRequired = 2
    twoTouchTapRecognizer.addTarget(self, action: "handleTwoTouchTapGesture:")
    addGestureRecognizer(twoTouchTapRecognizer)
  }


  /// MARK: Touch event handlers.
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let stroke = MutableStroke(color: paintColor, brush: brush)
      stroke.appendPoint(touch.locationInView(self))
      pendingStrokeTuples.append(RenderingStrokeTuple(
          touchPointerId: unsafeAddressOf(touch), isCancelled: false,
          stroke: stroke))
    }

    if shouldRenderPendingStrokes {
      self.pendingStrokeRenderer?.renderStrokes(pendingStrokes)
    } else {
      cancelRenderingStrokes()
    }
  }
  
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let location = touch.locationInView(self)
      let touchPointerId = unsafeAddressOf(touch)

      // Update the location-stroke pairs, updating the pair associated with
      // the given touch and extending the stroke to the new touch location.
      for t in pendingStrokeTuples {
        if t.touchPointerId == touchPointerId {
          t.stroke.appendPoint(location)
        }
      }
    }

    if shouldRenderPendingStrokes {
      self.pendingStrokeRenderer?.renderStrokes(pendingStrokes)
    }
  }
  
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let tupleCountPriorToTouchEnd = pendingStrokeTuples.count
    var completedStrokes: [Stroke] = []
    
    for touch in touches {
      let location = touch.locationInView(self)
      let touchPointerId = unsafeAddressOf(touch)

      // Update the location stroke pairs, droping pairs associated with the
      // touch that has ended.
      pendingStrokeTuples = pendingStrokeTuples.filter {
        // If the pending stroke is not associated with the end location then
        // do not end the stroke.
        if ($0.touchPointerId != touchPointerId) {
          return true
        }
        
        $0.stroke.appendPoint(location)
        if !$0.isCancelled {
          completedStrokes.append($0.stroke)
        }

        return false
      }
    }

    if shouldRenderPendingStrokes {
      pendingStrokeRenderer?.renderStrokes(pendingStrokes)
      drawingInteractionDelegate?.completeStrokes(completedStrokes)
    }

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


  /// MARK: Gesture handlers.

  @objc func handleTwoTouchTapGesture(
      twoTouchTapRecognizer: UITapGestureRecognizer) {
    drawingInteractionDelegate?.toggleTool()
  }


  /// MARK: Helper methods.

  func cancelRenderingStrokes() {
    pendingStrokeTuples = pendingStrokeTuples.map {
      return RenderingStrokeTuple(
          touchPointerId: $0.touchPointerId, isCancelled: true,
          stroke: $0.stroke)
    }
    pendingStrokeRenderer?.renderStrokes([])
  }


  /// MARK: UIResponder method overrides.

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
