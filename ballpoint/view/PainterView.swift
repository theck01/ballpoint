//
//  PainterOverlayView.swift
//  inkwell
//
//  Created by Tyler Heck on 8/4/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



protocol PendingStrokeDelegate {
  /**
   Informs the delegate that pending strokes have been updated.

   :param: strokes The pending strokes that have been updated.
   */
  func updatePendingStrokes(stroke: [MutableStroke])

  /**
   Informs the delegate that the given strokes have been completed and are no
   longer pending.
  
   :param: stroke The stroke that has been completed.
   */
  func completePendingStrokes(strokes: [Stroke])

  /**
   Informs the delegate that all pending strokes have been cancelled.
   */
  func cancelPendingStrokes()
}



/// View that transforms user interaction events into drawing and application
/// actions.
class PainterView: UIView {


  /// A tuple containing all information required to process pending strokes.
  private struct PendingStrokeTuple {
    /// The last touch location associated with the pending stroke.
    var location: CGPoint

    /// Whether the pending stroke has been cancelled and is just being kept
    /// around for bookkeeping.
    var isCancelled: Bool

    /// The underlying stroke object.
    let stroke: MutableStroke
  }

  private static let kMinimumUndoVelocityThreshold: CGFloat = 40

  /// The brush used to create strokes on the canvas.
  var brush: Brush
  
  /// The color of the strokes to paint.
  var paintColor: UIColor
  
  var drawingInteractionDelegate: DrawingInteractionDelegate?

  var pendingStrokeDelegate: PendingStrokeDelegate?

  var undoDirectionController: DirectedActionController!

  /// An array of touch locations and pending strokes that last were updated to
  /// that location.
  private var pendingStrokeTuples: [PendingStrokeTuple] = []

  private var pendingStrokes: [MutableStroke] {
    return pendingStrokeTuples.map { $0.stroke }
  }

  /// Whether the pending strokes updates should be forwarded to the delegate.
  private var displayPendingStrokes: Bool {
    return pendingStrokeTuples.count < 2 &&
        (!(pendingStrokeTuples.first?.isCancelled ?? false))
  }
  
  // The gesture recognizers that map to application actions.
  private let twoTouchPanRecognizer: UIPanGestureRecognizer
  private let twoTouchTapRecognizer: UITapGestureRecognizer

  
  /**
   Initializes the painter with the given brush, canvas, and paint color. The
   frame of the painter is set to the frame of the canvas.

   :param: brush The initial brush used to create strokes.
   :param: paintColor The initial color of strokes to generate.
   */
  init(brush: Brush, paintColor: UIColor, frame: CGRect = CGRectZero) {
    self.brush = brush
    self.paintColor = paintColor
    twoTouchPanRecognizer = UIPanGestureRecognizer()
    twoTouchTapRecognizer = UITapGestureRecognizer()

    super.init(frame: frame)

    undoDirectionController = DirectedActionController(
        primaryAction: { self.drawingInteractionDelegate?.undo() },
        secondaryAction: { self.drawingInteractionDelegate?.redo() })

    multipleTouchEnabled = true

    twoTouchPanRecognizer.cancelsTouchesInView = true
    twoTouchPanRecognizer.delaysTouchesBegan = false
    twoTouchPanRecognizer.delaysTouchesEnded = false
    twoTouchPanRecognizer.minimumNumberOfTouches = 2
    twoTouchPanRecognizer.maximumNumberOfTouches = 2
    twoTouchPanRecognizer.addTarget(self, action: "handleTwoTouchPanGesture:")
    addGestureRecognizer(twoTouchPanRecognizer)

    twoTouchTapRecognizer.cancelsTouchesInView = true
    twoTouchTapRecognizer.delaysTouchesBegan = false
    twoTouchTapRecognizer.delaysTouchesEnded = false
    twoTouchTapRecognizer.numberOfTapsRequired = 1
    twoTouchTapRecognizer.numberOfTouchesRequired = 2
    twoTouchTapRecognizer.addTarget(self, action: "handleTwoTouchTapGesture:")
    addGestureRecognizer(twoTouchTapRecognizer)
  }


  /// MARK: Touch event handlers.
  
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    for touch in touches {
      if let t = touch as? UITouch {
        let location = t.locationInView(self)
        let stroke = brush.beginStrokeWithColor(
            self.paintColor, atLocation: location)
        pendingStrokeTuples.append(PendingStrokeTuple(
            location: location, isCancelled: false, stroke: stroke))
      }
    }

    if displayPendingStrokes {
      self.pendingStrokeDelegate?.updatePendingStrokes(pendingStrokes)
    } else {
      cancelPendingStrokes()
    }
  }
  
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    for touch in touches {
      if let t = touch as? UITouch {
        let location = t.locationInView(self)
        let previousLocation = t.previousLocationInView(self)
        
        // Update the location-stroke pairs, updating the pair associated with
        // the given touch and extending the stroke to the new touch location.
        pendingStrokeTuples = pendingStrokeTuples.map {
          if $0.location == previousLocation {
            self.brush.extendStroke(
                $0.stroke, fromLocation: previousLocation, toLocation: location)
            return PendingStrokeTuple(
                location: location, isCancelled: $0.isCancelled,
                stroke: $0.stroke)
          } else {
            return $0
          }
        }
      }
    }

    if displayPendingStrokes {
      self.pendingStrokeDelegate?.updatePendingStrokes(pendingStrokes)
    }
  }
  
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    let tupleCountPriorToTouchEnd = pendingStrokeTuples.count
    var completedStrokes: [Stroke] = []
    
    for touch in touches {
      if let t = touch as? UITouch {
        let location = t.locationInView(self)
        let previousLocation = t.previousLocationInView(self)
        
        // Update the location stroke pairs, droping pairs associated with the
        // touch that has ended.
        pendingStrokeTuples = pendingStrokeTuples.filter {
          // If the pending stroke is not associated with the end location then
          // do not end the stroke.
          if ($0.location != location && $0.location != previousLocation) {
            return true
          }
          
          // If the end position of the touch has not yet been appended to the
          // stroke during a -touchesMoved call then extend the stroke.
          if $0.location == previousLocation && location != previousLocation {
            self.brush.extendStroke(
                $0.stroke, fromLocation: previousLocation, toLocation: location)
          }

          if !$0.isCancelled {
            completedStrokes.append($0.stroke)
          }

          /// Once a stroke is completed the undo action direction should be
          /// cleared.
          self.undoDirectionController.primaryActionDirection = nil
          
          return false
        }
      }
    }

    if displayPendingStrokes {
      self.pendingStrokeDelegate?.updatePendingStrokes(pendingStrokes)
      self.pendingStrokeDelegate?.completePendingStrokes(completedStrokes)
      self.drawingInteractionDelegate?.completeStrokes(completedStrokes)
    }

    assert(
        tupleCountPriorToTouchEnd - touches.count ==
            pendingStrokeTuples.count,
        "A different number of strokes were ended than touches")
  }
  
  
  override func touchesCancelled(
      touches: Set<NSObject>!, withEvent event: UIEvent!) {
    pendingStrokeTuples = []
    pendingStrokeDelegate?.cancelPendingStrokes()
  }


  /// MARK: Motion event handlers.

  override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
    if motion == UIEventSubtype.MotionShake {
      drawingInteractionDelegate?.clearDrawing()
    }
  }


  /// MARK: Gesture handlers.

  @objc func handleTwoTouchPanGesture(
      twoTouchPanRecognizer: UIPanGestureRecognizer) {
    if twoTouchPanRecognizer.state == UIGestureRecognizerState.Ended {
      let velocity = twoTouchPanRecognizer.velocityInView(self)
      if velocity.x * velocity.x + velocity.y * velocity.y >=
          PainterView.kMinimumUndoVelocityThreshold *
          PainterView.kMinimumUndoVelocityThreshold {
        let direction = CGVector(dx: velocity.x, dy: velocity.y)
        undoDirectionController.triggerActionForDirection(direction)
      }
    }
  }


  @objc func handleTwoTouchTapGesture(
      twoTouchTapRecognizer: UITapGestureRecognizer) {
    drawingInteractionDelegate?.toggleTool()
  }


  /// MARK: Helper methods.

  func cancelPendingStrokes() {
    pendingStrokeTuples = pendingStrokeTuples.map {
      return PendingStrokeTuple(
          location: $0.location, isCancelled: true, stroke: $0.stroke)
    }
  }


  /// MARK: UIResponder method overrides.

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

  
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
