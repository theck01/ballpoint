//
//  ViewController.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingViewController: UIViewController, PainterTouchDelegate,
    RendererColorPaletteUpdateListener {
  // The constants describing the shadow behind the canvas backing.
  static let kCanvasAbsentTouchShadowOpacity: CGFloat = 0.4
  static let kCanvasAbsentTouchShadowRadius: CGFloat =
      Constants.kCanvasScreenSeparation / 2
  static let kCanvasAbsentTouchShadowYOffset: CGFloat = 0
  static let kCanvasActiveTouchShadowOpacity: CGFloat =
      DrawingViewController.kCanvasAbsentTouchShadowOpacity / 2
  static let kCanvasActiveTouchShadowRadius: CGFloat =
      DrawingViewController.kCanvasAbsentTouchShadowRadius / 2
  static let kCanvasActiveTouchShadowYOffset: CGFloat = 0
  
  /// The duration of the shadow animation when painter touches are active.
  static let kPainterTouchesActiveAnimationDuration: NSTimeInterval = 0.2
  
  /// The duration of the shadow animation when painter touches are active.
  static let kUpdateViewAnimationDuration: NSTimeInterval = 0.2

  /// The distance travelled when animating changes to the drawing snapshot.
  static let kUpdateViewTranslationDistance: CGFloat = 50

  /// The backing view of the canvas.
  let canvasBackingView: UIView

  /// The image view that displays the rendered drawing.
  let drawingImageView: UIImageView

  /// The view that displays pending drawing strokes.
  let pendingStrokeRenderer: StrokeRendererView

  /// The painter view that handles all user interaction.
  let painterView: PainterView

  var drawingInteractionDelegate: DrawingInteractionDelegate? {
    get {
      return painterView.drawingInteractionDelegate
    }
    set {
      painterView.drawingInteractionDelegate = newValue
    }
  }


  init() {
    let canvasFrame = CGRect(
        origin: CGPoint(
            x: Constants.kCanvasScreenSeparation,
            y: Constants.kCanvasScreenSeparation),
        size: Constants.kDrawingSize)

    canvasBackingView = UIView(frame: canvasFrame)
    drawingImageView = UIImageView(frame: canvasFrame)
    pendingStrokeRenderer = StrokeRendererView(frame: canvasFrame)
    painterView = PainterView(
        brush: CircularBrush(radius: Constants.kPenBrushSize),
        paintColor: RendererColorPalette.defaultPalette[
            Constants.kBallpointInkColorId],
        frame: canvasFrame)

    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = UIColor.launchScreenBackgroundColor()
    canvasBackingView.backgroundColor = RendererColorPalette.defaultPalette[
        Constants.kBallpointSurfaceColorId].backingColor
    drawingImageView.backgroundColor = UIColor.clearColor()
    pendingStrokeRenderer.backgroundColor = UIColor.clearColor()
    painterView.backgroundColor = UIColor.clearColor()

    canvasBackingView.alpha = 0
    drawingImageView.alpha = 0
    pendingStrokeRenderer.alpha = 0

    view.addSubview(canvasBackingView)
    view.addSubview(drawingImageView)
    view.addSubview(pendingStrokeRenderer)
    view.addSubview(painterView)

    painterView.pendingStrokeRenderer = pendingStrokeRenderer
    painterView.painterTouchDelegate = self

    RendererColorPalette.defaultPalette.registerColorPaletteUpdateListener(
        self)
  }


  /**
   Updates the visible drawing to match the snapshot.

   - parameter snapshot:
   */
  func updateDrawingSnapshot(snapshot: UIImage) {
    drawingImageView.image = snapshot
  }


  /**
   Updates the visible drawing to match the snapshot, animating the added
   strokes to slide in and become opaque.

   - parameter snapshot:
   - parameter addedStrokes:
   */
  func updateDrawingSnapshot(snapshot: UIImage, addedStrokes: [Stroke]) {
    let addFromDirection =
        painterView.mostRecentSwipeDirection.vectorWithMagnitude(
            -DrawingViewController.kUpdateViewTranslationDistance)

    let addedStrokeRendererView = StrokeRendererView(frame: CGRectOffset(
        canvasBackingView.frame, addFromDirection.dx, addFromDirection.dy))
    addedStrokeRendererView.alpha = 0
    addedStrokeRendererView.backgroundColor = UIColor.clearColor()
    addedStrokeRendererView.renderStrokes(addedStrokes)
    view.addSubview(addedStrokeRendererView)

    view.bringSubviewToFront(pendingStrokeRenderer)
    view.bringSubviewToFront(painterView)

    UIView.animateWithDuration(
        DrawingViewController.kUpdateViewAnimationDuration,
        animations: {
          addedStrokeRendererView.frame = self.canvasBackingView.frame
          addedStrokeRendererView.alpha = 1
        },
        completion: { (completed: Bool) in
          self.drawingImageView.image = snapshot
          addedStrokeRendererView.removeFromSuperview()
        })
  }


  /**
   Updates the visible drawing to match the snapshot, animating the removed
   strokes to slide and disappear away.

   - parameter snapshot:
   - parameter removedStrokes:
   */
  func updateDrawingSnapshot(snapshot: UIImage, removedStrokes: [Stroke]) {
    let removeToDirection =
        painterView.mostRecentSwipeDirection.vectorWithMagnitude(
            DrawingViewController.kUpdateViewTranslationDistance)

    let removedStrokeRendererView =
        StrokeRendererView(frame: canvasBackingView.frame)
    removedStrokeRendererView.backgroundColor = UIColor.clearColor()
    removedStrokeRendererView.renderStrokes(removedStrokes)
    view.addSubview(removedStrokeRendererView)

    view.bringSubviewToFront(pendingStrokeRenderer)
    view.bringSubviewToFront(painterView)

    self.drawingImageView.image = snapshot

    UIView.animateWithDuration(
        DrawingViewController.kUpdateViewAnimationDuration,
        animations: {
          removedStrokeRendererView.frame = CGRectOffset(
              self.canvasBackingView.frame, removeToDirection.dx,
              removeToDirection.dy)
          removedStrokeRendererView.alpha = 0
        },
        completion: { (completed: Bool) in
          removedStrokeRendererView.removeFromSuperview()
        })
  }


  /// MARK: PainterTouchDelegate methods

  func painterTouchesActive() {
    canvasBackingView.animateShadowAppearanceWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        shadowOpacity: DrawingViewController.kCanvasActiveTouchShadowOpacity,
        shadowRadius: DrawingViewController.kCanvasActiveTouchShadowRadius,
        shadowYOffset: DrawingViewController.kCanvasActiveTouchShadowYOffset)
  }


  func painterTouchesAbsent() {
    canvasBackingView.animateShadowAppearanceWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        shadowOpacity: DrawingViewController.kCanvasAbsentTouchShadowOpacity,
        shadowRadius: DrawingViewController.kCanvasAbsentTouchShadowRadius,
        shadowYOffset: DrawingViewController.kCanvasAbsentTouchShadowYOffset)
  }


  /// MARK: RendererColorPaletteUpdateListener methods

  func didUpdateRenderColorPalette(palette: RendererColorPalette) {
    pendingStrokeRenderer.setNeedsDisplay()
    canvasBackingView.backgroundColor =
        palette[Constants.kBallpointSurfaceColorId].backingColor
  }


  /// MARK: UIViewController method overrides.

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    canvasBackingView.animateShadowAppearanceWithDuration(
        Constants.kViewControllerAppearDuration,
        shadowOpacity: DrawingViewController.kCanvasAbsentTouchShadowOpacity,
        shadowRadius: DrawingViewController.kCanvasAbsentTouchShadowRadius,
        shadowYOffset: DrawingViewController.kCanvasAbsentTouchShadowYOffset)

    UIView.animateWithDuration(Constants.kViewControllerAppearDuration) {
      self.canvasBackingView.alpha = 1
      self.drawingImageView.alpha = 1
      self.pendingStrokeRenderer.alpha = 1
      self.painterView.alpha = 1
    }

    painterView.becomeFirstResponder()
  }


  override func viewDidDisappear(animated: Bool) {
    painterView.resignFirstResponder()
    
    canvasBackingView.alpha = 0
    canvasBackingView.layer.shadowOpacity = 0
    canvasBackingView.layer.shadowRadius = 0
    canvasBackingView.layer.shadowOffset = CGSizeZero

    drawingImageView.alpha = 0
    pendingStrokeRenderer.alpha = 0

    super.viewDidDisappear(animated)
  }


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
