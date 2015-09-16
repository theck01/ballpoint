//
//  ViewController.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingViewController: UIViewController, DrawingUpdateListener,
    PainterTouchDelegate, RendererColorPaletteUpdateListener {
  // The constants describing the shadow behind the canvas backing.
  static let kCanvasAbsentTouchShadowOpacity: CGFloat = 0.5
  static let kCanvasAbsentTouchShadowRadius: CGFloat = 4
  static let kCanvasAbsentTouchShadowYOffset: CGFloat = 4
  static let kCanvasActiveTouchShadowOpacity: CGFloat = 0.2
  static let kCanvasActiveTouchShadowRadius: CGFloat = 2
  static let kCanvasActiveTouchShadowYOffset: CGFloat = 2

  /// The duration of the shadow animation when painter touches are active.
  static let kPainterTouchesActiveAnimationDuration: NSTimeInterval = 0.2

  /// The backing view of the canvas.
  let canvasBackingView: UIView

  /// The image view that displays the rendered drawing.
  let drawingImageView: UIImageView

  /// The view that displays pending drawing strokes.
  let pendingDrawingView: PendingDrawingView

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
            x: Constants.kMinimumCanvasScreenSeparation,
            y: Constants.kMinimumCanvasScreenSeparation +
                Constants.kButtonSize),
        size: Constants.kDrawingSize)

    canvasBackingView = UIView(frame: canvasFrame)
    drawingImageView = UIImageView(frame: canvasFrame)
    pendingDrawingView = PendingDrawingView(frame: canvasFrame)
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
    pendingDrawingView.backgroundColor = UIColor.clearColor()
    painterView.backgroundColor = UIColor.clearColor()

    canvasBackingView.alpha = 0
    drawingImageView.alpha = 0
    pendingDrawingView.alpha = 0

    view.addSubview(canvasBackingView)
    view.addSubview(drawingImageView)
    view.addSubview(pendingDrawingView)
    view.addSubview(painterView)

    painterView.pendingStrokeDelegate = pendingDrawingView
    painterView.painterTouchDelegate = self

    RendererColorPalette.defaultPalette.registerColorPaletteUpdateListener(
        self)
  }


  /// MARK: PainterTouchDelegate methods

  func painterTouchesActive() {
    animateShadowAppearanceWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        shadowOpacity: DrawingViewController.kCanvasActiveTouchShadowOpacity,
        shadowRadius: DrawingViewController.kCanvasActiveTouchShadowRadius,
        shadowYOffset: DrawingViewController.kCanvasActiveTouchShadowYOffset)
  }


  func painterTouchesAbsent() {
    animateShadowAppearanceWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        shadowOpacity: DrawingViewController.kCanvasAbsentTouchShadowOpacity,
        shadowRadius: DrawingViewController.kCanvasAbsentTouchShadowRadius,
        shadowYOffset: DrawingViewController.kCanvasAbsentTouchShadowYOffset)
  }


  /// MARK: DrawingUpdateListener methods

  func drawingSnapshotUpdated(snapshot: UIImage) {
    drawingImageView.image = snapshot
  }


  /// MARK: RendererColorPaletteUpdateListener methods

  func didUpdateRenderColorPalette(palette: RendererColorPalette) {
    pendingDrawingView.setNeedsDisplay()
    canvasBackingView.backgroundColor =
        palette[Constants.kBallpointSurfaceColorId].backingColor
  }


  /// MARK: UIViewController method overrides.

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    animateShadowAppearanceWithDuration(
        Constants.kViewControllerAppearDuration,
        shadowOpacity: DrawingViewController.kCanvasAbsentTouchShadowOpacity,
        shadowRadius: DrawingViewController.kCanvasAbsentTouchShadowRadius,
        shadowYOffset: DrawingViewController.kCanvasAbsentTouchShadowYOffset)

    UIView.animateWithDuration(Constants.kViewControllerAppearDuration) {
      self.canvasBackingView.alpha = 1
      self.drawingImageView.alpha = 1
      self.pendingDrawingView.alpha = 1
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
    pendingDrawingView.alpha = 0

    super.viewDidDisappear(animated)
  }


  /// MARK: Private methods

  /**
   Animate the canvas's shadow appearance to the given opacity, radius, and
   offset.

   :param: shadowOpacity
   :param: shadowRadius
   :param: shadowYOffset
   */
  func animateShadowAppearanceWithDuration(
      duration: NSTimeInterval, shadowOpacity: CGFloat, shadowRadius: CGFloat,
      shadowYOffset: CGFloat) {
    let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
    shadowOpacityAnimation.fromValue = NSNumber(
        double: Double(canvasBackingView.layer.shadowOpacity))
    shadowOpacityAnimation.toValue = NSNumber(double: Double(shadowOpacity))
    shadowOpacityAnimation.duration = duration
    shadowOpacityAnimation.fillMode =
        Float(shadowOpacity) > canvasBackingView.layer.shadowOpacity ?
            kCAFillModeForwards :
            kCAFillModeBackwards
    canvasBackingView.layer.addAnimation(
        shadowOpacityAnimation, forKey: "shadowOpacity")
    canvasBackingView.layer.shadowOpacity = Float(shadowOpacity)

    let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
    shadowRadiusAnimation.fromValue = NSNumber(
        double: Double(canvasBackingView.layer.shadowRadius))
    shadowRadiusAnimation.toValue = NSNumber(double: Double(shadowRadius))
    shadowRadiusAnimation.duration = duration
    shadowRadiusAnimation.fillMode =
        shadowRadius > canvasBackingView.layer.shadowRadius ?
            kCAFillModeForwards :
            kCAFillModeBackwards
    canvasBackingView.layer.addAnimation(
        shadowRadiusAnimation, forKey: "shadowRadius")
    canvasBackingView.layer.shadowRadius = shadowRadius

    let endShadowOffset = CGSize(width: 0, height: shadowYOffset)
    let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
    shadowOffsetAnimation.fromValue = NSValue(
        CGSize: canvasBackingView.layer.shadowOffset)
    shadowOffsetAnimation.toValue = NSValue(CGSize: endShadowOffset)
    shadowOffsetAnimation.duration = duration
    shadowRadiusAnimation.fillMode =
        shadowYOffset > canvasBackingView.layer.shadowOffset.height ?
            kCAFillModeForwards :
            kCAFillModeBackwards
    canvasBackingView.layer.addAnimation(
        shadowOffsetAnimation, forKey: "shadowOffset")
    canvasBackingView.layer.shadowOffset = endShadowOffset
  }
  
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
