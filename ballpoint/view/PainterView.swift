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



protocol PainterStrokeScaleProvider {
  /**
   - returns: The scale factor that should be applied to stroke points.
   */
  func getStrokeScaleFactor() -> CGFloat
}



/// View that transforms user interaction events into drawing and application
/// actions.
class PainterView: UIView {

  /// A tuple containing all information required to process pending strokes.
  fileprivate struct RenderingStrokeTuple {
    /// The raw address of the UITouch object used to generate the stroke.
    let touchPointerId: UnsafeRawPointer

    /// The underlying stroke object.
    let stroke: MutableStroke
  }

  /// The minimum proportional stroke size from a light 3d touch.
  fileprivate static let kMinProportionalStrokeRadius: CGFloat =
      Constants.kProportionalStrokeRadius * 0.75

  /// The maximum proportional stroke size from a strong 3d touch.
  fileprivate static let kMaxProportionalStrokeRadius: CGFloat =
      Constants.kProportionalStrokeRadius * 2

  /// The brush used to create strokes on the canvas.
  var brush: Brush
  
  /// The color of the strokes to paint.
  var paintColor: RendererColor
  
  var drawingInteractionDelegate: DrawingInteractionDelegate?

  var pendingStrokeRenderer: StrokeRenderer?

  var painterTouchDelegate: PainterTouchDelegate?

  var painterStrokeScaleProvider: PainterStrokeScaleProvider?

  /// An array of touch locations and pending strokes that last were updated to
  /// that location.
  fileprivate var pendingStrokeTuples: [RenderingStrokeTuple] = [] {
    didSet {
      if pendingStrokeTuples.count > 0 && oldValue.count == 0 {
        painterTouchDelegate?.painterTouchesActive()
      } else if pendingStrokeTuples.count == 0 && oldValue.count > 0 {
        painterTouchDelegate?.painterTouchesAbsent()
      }
    }
  }

  fileprivate var pendingStrokes: [MutableStroke] {
    return pendingStrokeTuples.map { $0.stroke }
  }


  /**
   Initializes the painter with the given brush, canvas, and paint color. The
   frame of the painter is set to the frame of the canvas.

   - parameter brush: The initial brush used to create strokes.
   - parameter paintColor: The initial color of strokes to generate.
   */
  init(brush: Brush, paintColor: RendererColor, frame: CGRect = CGRect.zero) {
    self.brush = brush
    self.paintColor = paintColor

    super.init(frame: frame)

    isMultipleTouchEnabled = true
  }


  func createStrokePointFromTouch(_ touch: UITouch) -> Stroke.Point {
    if #available(iOS 9.0, *) {
      if (traitCollection.forceTouchCapability ==
          UIForceTouchCapability.available) {
        let forceTouchFactor = touch.force / touch.maximumPossibleForce
        let proportionalRadius =
            (PainterView.kMaxProportionalStrokeRadius -
            PainterView.kMinProportionalStrokeRadius) * forceTouchFactor +
            PainterView.kMinProportionalStrokeRadius
        let radius = proportionalRadius *
            (painterStrokeScaleProvider?.getStrokeScaleFactor() ?? 1)
        return Stroke.Point(
            location: touch.location(in: self),
            radius: radius)
      }
    }
    return Stroke.Point(
        location: touch.location(in: self),
        radius: Constants.kProportionalStrokeRadius *
            (painterStrokeScaleProvider?.getStrokeScaleFactor() ?? 1))
  }


  // MARK: Touch event handlers.
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let stroke = MutableStroke(color: paintColor, brush: brush)
      stroke.appendPoint(createStrokePointFromTouch(touch))
      pendingStrokeTuples.append(RenderingStrokeTuple(
          touchPointerId: Unmanaged.passUnretained(touch).toOpaque(), stroke: stroke))
    }

    self.pendingStrokeRenderer?.renderStrokes(pendingStrokes)
  }
  
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let touchPointerId = Unmanaged.passUnretained(touch).toOpaque()

      // Update the location-stroke pairs, updating the pair associated with
      // the given touch and extending the stroke to the new touch location.
      for t in pendingStrokeTuples {
        if t.touchPointerId == UnsafeRawPointer(touchPointerId) {
          t.stroke.appendPoint(createStrokePointFromTouch(touch))
        }
      }
    }

    self.pendingStrokeRenderer?.renderStrokes(pendingStrokes)
  }
  
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let tupleCountPriorToTouchEnd = pendingStrokeTuples.count
    var activeCompletedStrokes: [Stroke] = []
    
    for touch in touches {
      let touchPointerId = Unmanaged.passUnretained(touch).toOpaque()

      // Update the location stroke pairs, droping pairs associated with the
      // touch that has ended.
      pendingStrokeTuples = pendingStrokeTuples.filter {
        // If the pending stroke is not associated with the end location then
        // do not end the stroke.
        if ($0.touchPointerId != UnsafeRawPointer(touchPointerId)) {
          return true
        }

        // If the touch ended at a different location than the previous location
        // then append the final location to the stroke.
        let location = touch.location(in: self)
        if !(location =~= touch.previousLocation(in: self)) {
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
      _ touches: Set<UITouch>, with event: UIEvent?) {
    /// Clear the strokes cancelled due to touch cancellation rather than just
    /// cancelling, as these strokes will never be ended by -touchesEnded.
    pendingStrokeTuples = []
    pendingStrokeRenderer?.renderStrokes(pendingStrokes)
  }


  // MARK: UIResponder method overrides.

  override var canBecomeFirstResponder : Bool {
    return true
  }

  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
