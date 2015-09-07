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
   Informs the delegate that a pending stroke has been updated.

   :param: stroke The pending stroke that has been updated.
   */
  func updatePendingStroke(stroke: MutableStroke)

  /**
   Informs the delegate that the given stroke has been completed and is no
   longer pending.
  
   :param: stroke The stroke that has been completed.
   */
  func completePendingStroke(stroke: Stroke)

  /**
   Informs the delegate that all pending strokes have been cancelled.
   */
  func cancelPendingStrokes()
}



/// View that transforms user interaction events into drawing and application
/// actions.
class PainterView: UIView {
  /// The brush used to create strokes on the canvas.
  var brush: Brush
  
  /// The color of the strokes to paint.
  var paintColor: UIColor
  
  var drawingInteractionDelegate: DrawingInteractionDelegate?

  var pendingStrokeDelegate: PendingStrokeDelegate?

  var undoDirectionController: DirectedActionController!

  /// An array of touch locations and pending strokes that last were updated to
  /// that location.
  private var locationPendingStrokePairs:
      [(location: CGPoint, stroke: MutableStroke)] = []
  
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
        
        locationPendingStrokePairs.append((location: location, stroke: stroke))
        pendingStrokeDelegate?.updatePendingStroke(stroke)
      }
    }
  }
  
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    for touch in touches {
      if let t = touch as? UITouch {
        let location = t.locationInView(self)
        let previousLocation = t.previousLocationInView(self)
        
        // Update the location-stroke pairs, updating the pair associated with
        // the given touch and extending the stroke to the new touch location.
        locationPendingStrokePairs = locationPendingStrokePairs.map {
          if $0.location == previousLocation {
            self.brush.extendStroke(
                $0.stroke, fromLocation: previousLocation, toLocation: location)
            self.pendingStrokeDelegate?.updatePendingStroke($0.stroke)
            return (location: location, stroke: $0.stroke)
          } else {
            return $0
          }
        }
      }
    }
  }
  
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    let pairsCountPriorToTouchEnd = locationPendingStrokePairs.count
    
    for touch in touches {
      if let t = touch as? UITouch {
        let location = t.locationInView(self)
        let previousLocation = t.previousLocationInView(self)
        
        // Update the location stroke pairs, droping pairs associated with the
        // touch that has ended.
        locationPendingStrokePairs = locationPendingStrokePairs.filter {
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
            self.pendingStrokeDelegate?.updatePendingStroke($0.stroke)
          }
          
          self.drawingInteractionDelegate?.completeStroke($0.stroke);
          self.pendingStrokeDelegate?.completePendingStroke($0.stroke);

          /// Once a stroke is completed the undo action direction should be
          /// cleared.
          self.undoDirectionController.primaryActionDirection = nil
          
          return false
        }
      }
    }
    
    assert(
        pairsCountPriorToTouchEnd - touches.count ==
            locationPendingStrokePairs.count,
        "A different number of strokes were ended than touches")
  }
  
  
  override func touchesCancelled(
      touches: Set<NSObject>!, withEvent event: UIEvent!) {
    locationPendingStrokePairs = []
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
      let direction = CGVector(dx: velocity.x, dy: velocity.y)
      undoDirectionController.triggerActionForDirection(direction)
    }
  }


  @objc func handleTwoTouchTapGesture(
      twoTouchTapRecognizer: UITapGestureRecognizer) {
    drawingInteractionDelegate?.toggleTool()
  }


  /// MARK: UIResponder method overrides.

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

  
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
