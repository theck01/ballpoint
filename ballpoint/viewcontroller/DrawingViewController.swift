//
//  ViewController.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingViewController: UIViewController, DrawingUpdateListener,
    RendererColorPaletteUpdateListener {
  // The constants describing the shadow behind the canvas backing.
  static let kCanvasShadowOpacity: CGFloat = 0.5
  static let kCanvasShadowRadius: CGFloat = 4
  static let kCanvasShadowYOffset: CGFloat = 4

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
    painterView.alpha = 0

    view.addSubview(canvasBackingView)
    view.addSubview(drawingImageView)
    view.addSubview(pendingDrawingView)
    view.addSubview(painterView)

    painterView.pendingStrokeDelegate = pendingDrawingView

    RendererColorPalette.defaultPalette.registerColorPaletteUpdateListener(
        self)
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

    let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
    shadowOpacityAnimation.fromValue = NSNumber(double: 0)
    shadowOpacityAnimation.toValue =
        NSNumber(double: Double(DrawingViewController.kCanvasShadowOpacity))
    shadowOpacityAnimation.duration = 2 * Constants.kDefaultAnimationDuration
    shadowOpacityAnimation.fillMode = kCAFillModeForwards
    canvasBackingView.layer.addAnimation(
        shadowOpacityAnimation, forKey: "shadowOpacity")
    canvasBackingView.layer.shadowOpacity =
        Float(DrawingViewController.kCanvasShadowOpacity)

    let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
    shadowRadiusAnimation.fromValue = NSNumber(double: 0)
    shadowRadiusAnimation.toValue =
        NSNumber(double: Double(DrawingViewController.kCanvasShadowRadius))
    shadowRadiusAnimation.duration = 2 * Constants.kDefaultAnimationDuration
    shadowRadiusAnimation.fillMode = kCAFillModeForwards
    canvasBackingView.layer.addAnimation(
        shadowRadiusAnimation, forKey: "shadowRadius")
    canvasBackingView.layer.shadowRadius =
        DrawingViewController.kCanvasShadowRadius

    let endShadowOffset =
        CGSize(width: 0, height: DrawingViewController.kCanvasShadowYOffset)
    let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
    shadowOffsetAnimation.fromValue = NSValue(CGSize: CGSizeZero)
    shadowOffsetAnimation.toValue = NSValue(CGSize: endShadowOffset)
    shadowOffsetAnimation.duration = 2 * Constants.kDefaultAnimationDuration
    shadowOffsetAnimation.fillMode = kCAFillModeForwards
    canvasBackingView.layer.addAnimation(
        shadowOffsetAnimation, forKey: "shadowOffset")
    canvasBackingView.layer.shadowOffset = endShadowOffset

    UIView.animateWithDuration(Constants.kDefaultAnimationDuration) {
      self.canvasBackingView.alpha = 1
      self.drawingImageView.alpha = 1
      self.pendingDrawingView.alpha = 1
      self.painterView.alpha = 1
    }

    painterView.becomeFirstResponder()
  }


  override func viewDidDisappear(animated: Bool) {
    painterView.resignFirstResponder()
    
    canvasBackingView.alpha = 1
    drawingImageView.alpha = 1
    pendingDrawingView.alpha = 1
    painterView.alpha = 1

    super.viewDidDisappear(animated)
  }
  
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
