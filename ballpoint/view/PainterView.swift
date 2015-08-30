//
//  PainterOverlayView.swift
//  inkwell
//
//  Created by Tyler Heck on 8/4/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// Delegate responsible for handling the addition and removal of strokes.
protocol DrawingDelegate {
  /**
   Process the update of a pending strokes, which may be updated in the future.
  
   :param: stroke
   */
  func pendingStrokeUpdated(stroke: Stroke)


  /**
   Process the cancellation of all pending strokes.
   */
  func pendingStrokesCancelled()
  
  /**
   Process the completion of the given stroke, which will not be updated.
   
   :param: stroke
   */
  func strokeCompleted(stroke: Stroke)
}



/// View that transforms user interaction events into drawing and application
/// actions.
class PainterView: UIView {
  /// The brush used to create strokes on the canvas.
  var brush: Brush
  
  /// The color of the strokes to paint.
  var paintColor: UIColor
  
  var drawingDelegate: DrawingDelegate?
  var actionHandler: ActionHandler?
  
  /// An array of touch locations and pending strokes that last were updated to
  /// that location.
  private var locationPendingStrokePairs:
      [(location: CGPoint, stroke: MutableStroke)] = []
  
  /// The array of pending strokes in progress.
  var pendingStrokes: [Stroke] {
    return locationPendingStrokePairs.map { $0.stroke }
  }

  // The gesture recognizers that map to all application actions.
  let twoTouchPanRecognizer: UIPanGestureRecognizer
  let twoTouchTapRecognizer: UITapGestureRecognizer

  
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

    backgroundColor = UIColor.clearColor()

    twoTouchPanRecognizer.cancelsTouchesInView = true
    twoTouchPanRecognizer.minimumNumberOfTouches = 2
    twoTouchPanRecognizer.maximumNumberOfTouches = 2
    twoTouchPanRecognizer.addTarget(self, action: "handleTwoTouchPanGesture:")
    addGestureRecognizer(twoTouchPanRecognizer)

    twoTouchTapRecognizer.cancelsTouchesInView = true
    twoTouchTapRecognizer.numberOfTapsRequired = 1
    twoTouchTapRecognizer.numberOfTouchesRequired = 2
    twoTouchTapRecognizer.addTarget(self, action: "handleTwoTouchTapGesture:")
    addGestureRecognizer(twoTouchTapRecognizer)
  }
  
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    for touch in touches {
      if let t = touch as? UITouch {
        let location = t.locationInView(self)
        let stroke = brush.beginStrokeWithColor(
            self.paintColor, atLocation: location)
        
        drawingDelegate?.pendingStrokeUpdated(stroke)
        locationPendingStrokePairs.append((location: location, stroke: stroke))
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
            self.drawingDelegate?.pendingStrokeUpdated($0.stroke)
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
            self.drawingDelegate?.pendingStrokeUpdated($0.stroke)
          }
          
          self.drawingDelegate?.strokeCompleted($0.stroke);
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
    drawingDelegate?.pendingStrokesCancelled()
  }


  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
    if motion == UIEventSubtype.MotionShake {
      actionHandler?.handleClearCanvas()
    }
  }


  /// MARK: Gesture handlers.

  @objc func handleTwoTouchPanGesture(
    twoTouchPanRecognizer: UIPanGestureRecognizer) {
      println("Two touch pan gesture recognized!")
  }


  @objc func handleTwoTouchTapGesture(
    twoTouchTapRecognizer: UITapGestureRecognizer) {
      actionHandler?.handleToolToggle()
  }


  /// MARK: UIResponder method overrides.

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

  
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
