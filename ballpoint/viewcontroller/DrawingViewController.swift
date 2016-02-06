//
//  ViewController.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingViewController: UIViewController, PainterTouchDelegate,
    RendererColorPaletteUpdateListener, UIScrollViewDelegate {
  /// The separation between the canvas and the screen boundary.
  static let kCanvasMargin: CGFloat = 16

  // The shadow opacity behind the canvas backing.
  static let kCanvasActiveTouchShadowOpacity: CGFloat = 0.5
  static let kCanvasAbsentTouchShadowOpacity: CGFloat = 0.2

  // The shadow overflow behind the canvas backing
  static let kCanvasActiveTouchShadowOverflow: CGSize =
      CGSize(width: 1, height: 2)
  static let kCanvasAbsentTouchShadowOverflow: CGSize =
      CGSize(width: 3, height: 3)

  // The offsets of the shadow center from the canvas center
  static let kCanvasActiveTouchShadowOffset = CGPoint(x: 0, y: 1)
  static let kCanvasAbsentTouchShadowOffset = CGPoint(x: 0, y: 3)

  /// The duration of the canvas raise animation.
  static let kCanvasRaiseAnimationDuration: NSTimeInterval = 1

  /// The duration of the shadow animation when painter touches are active.
  static let kPainterTouchesActiveAnimationDuration: NSTimeInterval = 0.16

  // The minimum and maximum values for the zoom level of the root UIScrollView.
  static let kMaximumZoomLevel: CGFloat = 7
  static let kMinimumZoomLevel: CGFloat = 1

  /// The size of the view that renders the drawing.
  let drawingRenderViewSize: CGSize

  /// The root scroll view of the view hierarchy.
  let rootScrollView: UIScrollView

  /// The content container view of the view heirarchy.
  let contentContainerView: UIView

  /// The view of the canvas that provides a shadow.
  let canvasShadowView: UIView
  
  /// The backing view of the canvas.
  let canvasBackingView: UIView

  /// The image view that displays the rendered drawing.
  let drawingImageView: UIImageView

  /// The view that displays pending drawing strokes.
  let pendingStrokeRenderer: StrokeRendererView

  /// The painter view that handles all user interaction.
  let painterView: PainterView

  /// The two touch tap recongizer that handles the tool change gesture.
  private let twoTouchTapRecognizer: UITapGestureRecognizer

  var drawingInteractionDelegate: DrawingInteractionDelegate? {
    get {
      return painterView.drawingInteractionDelegate
    }
    set {
      painterView.drawingInteractionDelegate = newValue
    }
  }


  init() {
    drawingRenderViewSize = CGSize(
        width: UIScreen.mainScreen().bounds.size.width -
            2 * DrawingViewController.kCanvasMargin,
        height: UIScreen.mainScreen().bounds.size.height -
            2 * DrawingViewController.kCanvasMargin)

    let canvasFrame = CGRect(
        origin: CGPoint(
            x: DrawingViewController.kCanvasMargin,
            y: DrawingViewController.kCanvasMargin),
        size: drawingRenderViewSize)

    rootScrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    contentContainerView = UIView(frame: UIScreen.mainScreen().bounds)
    canvasShadowView = UIView(frame: canvasFrame)
    canvasBackingView = UIView(frame: canvasFrame)
    drawingImageView = UIImageView(frame: canvasFrame)
    pendingStrokeRenderer = StrokeRendererView(frame: canvasFrame)
    painterView = PainterView(
        brush: Constants.kPenBrush,
        paintColor: RendererColorPalette.defaultPalette[
            Constants.kBallpointInkColorId],
        frame: canvasFrame)
    twoTouchTapRecognizer = UITapGestureRecognizer()

    super.init(nibName: nil, bundle: nil)

    self.view = rootScrollView
    rootScrollView.addSubview(contentContainerView)
    contentContainerView.addSubview(canvasShadowView)
    contentContainerView.addSubview(canvasBackingView)
    contentContainerView.addSubview(drawingImageView)
    contentContainerView.addSubview(pendingStrokeRenderer)
    contentContainerView.addSubview(painterView)

    rootScrollView.backgroundColor = UIColor.launchScreenBackgroundColor()
    contentContainerView.backgroundColor = UIColor.launchScreenBackgroundColor()
    canvasShadowView.backgroundColor = UIColor.darkGrayColor()
    canvasBackingView.backgroundColor = RendererColorPalette.defaultPalette[
        Constants.kBallpointSurfaceColorId].backingColor
    drawingImageView.backgroundColor = UIColor.clearColor()
    pendingStrokeRenderer.backgroundColor = UIColor.clearColor()
    painterView.backgroundColor = UIColor.clearColor()

    rootScrollView.alwaysBounceHorizontal = true
    rootScrollView.alwaysBounceVertical = true
    rootScrollView.contentSize = rootScrollView.bounds.size
    rootScrollView.delaysContentTouches = false
    rootScrollView.delegate = self
    rootScrollView.maximumZoomScale = DrawingViewController.kMaximumZoomLevel
    rootScrollView.minimumZoomScale = DrawingViewController.kMinimumZoomLevel
    rootScrollView.panGestureRecognizer.cancelsTouchesInView = true
    rootScrollView.panGestureRecognizer.delaysTouchesEnded = true
    rootScrollView.panGestureRecognizer.delaysTouchesEnded = false
    rootScrollView.panGestureRecognizer.maximumNumberOfTouches = 2
    rootScrollView.panGestureRecognizer.minimumNumberOfTouches = 2
    if let scrollViewPinchRecognizer = rootScrollView.pinchGestureRecognizer {
      scrollViewPinchRecognizer.cancelsTouchesInView = true
      scrollViewPinchRecognizer.delaysTouchesBegan = false
      scrollViewPinchRecognizer.delaysTouchesEnded = false
    }

    canvasShadowView.alpha = 0
    canvasBackingView.alpha = 0

    painterView.pendingStrokeRenderer = pendingStrokeRenderer
    painterView.painterTouchDelegate = self

    twoTouchTapRecognizer.cancelsTouchesInView = true
    twoTouchTapRecognizer.delaysTouchesBegan = false
    twoTouchTapRecognizer.delaysTouchesEnded = false
    twoTouchTapRecognizer.numberOfTapsRequired = 1
    twoTouchTapRecognizer.numberOfTouchesRequired = 2
    twoTouchTapRecognizer.addTarget(self, action: "handleTwoTouchTapGesture:")
    painterView.addGestureRecognizer(twoTouchTapRecognizer)

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


  /// MARK: PainterTouchDelegate methods

  func painterTouchesActive() {
    UIView.animateWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        delay: 0,
        options: [
            UIViewAnimationOptions.BeginFromCurrentState,
            UIViewAnimationOptions.CurveEaseOut],
        animations: {
          let shadowSize = CGSize(
              width:
                  self.drawingRenderViewSize.width +
                  DrawingViewController.kCanvasActiveTouchShadowOverflow.width,
              height:
                  self.drawingRenderViewSize.height +
                  DrawingViewController.kCanvasActiveTouchShadowOverflow.height)
          self.canvasShadowView.frame =
              CGRect(origin: CGPoint.zero, size: shadowSize)
          self.canvasShadowView.center = CGPoint(
              x:
                  self.canvasBackingView.center.x +
                  DrawingViewController.kCanvasActiveTouchShadowOffset.x,
              y:
                  self.canvasBackingView.center.y +
                  DrawingViewController.kCanvasActiveTouchShadowOffset.y)


          self.canvasShadowView.alpha =
              DrawingViewController.kCanvasActiveTouchShadowOpacity
        },
        completion: nil)
  }


  func painterTouchesAbsent() {
    UIView.animateWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        delay: 0,
        options: [
            UIViewAnimationOptions.BeginFromCurrentState,
            UIViewAnimationOptions.CurveEaseOut],
        animations: {
          let shadowSize = CGSize(
              width:
                  self.drawingRenderViewSize.width +
                  DrawingViewController.kCanvasAbsentTouchShadowOverflow.width,
              height:
                  self.drawingRenderViewSize.height +
                  DrawingViewController.kCanvasAbsentTouchShadowOverflow.height)
          self.canvasShadowView.frame =
              CGRect(origin: CGPoint.zero, size: shadowSize)
          self.canvasShadowView.center = CGPoint(
              x:
                  self.canvasBackingView.center.x +
                  DrawingViewController.kCanvasAbsentTouchShadowOffset.x,
              y:
                  self.canvasBackingView.center.y +
                  DrawingViewController.kCanvasAbsentTouchShadowOffset.y)

          self.canvasShadowView.alpha =
              DrawingViewController.kCanvasAbsentTouchShadowOpacity
        },
        completion: nil)
  }


  /// MARK: RendererColorPaletteUpdateListener methods

  func didUpdateRenderColorPalette(palette: RendererColorPalette) {
    pendingStrokeRenderer.setNeedsDisplay()
    canvasBackingView.backgroundColor =
        palette[Constants.kBallpointSurfaceColorId].backingColor
  }


  /// MARK: UIScrollViewDelegate methods

  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return contentContainerView
  }


  func scrollViewDidZoom(scrollView: UIScrollView) {
    let horizontalInset: CGFloat = fmax(
        (scrollView.bounds.size.width - scrollView.contentSize.width) / 2,
        0)
    let verticalInset: CGFloat = fmax(
        (scrollView.bounds.size.height - scrollView.contentSize.height) / 2,
        0)

    // Center the content using insets if the content is smaller than the view
    // bounds.
    if horizontalInset != scrollView.contentInset.left ||
        verticalInset != scrollView.contentInset.top {
      scrollView.contentInset = UIEdgeInsets(
          top: verticalInset, left: horizontalInset, bottom: verticalInset,
          right: horizontalInset)
    }
  }


  /// MARK: UIViewController method overrides.

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    UIView.animateWithDuration(
        DrawingViewController.kCanvasRaiseAnimationDuration,
        delay: 0,
        options: UIViewAnimationOptions.CurveEaseOut,
        animations: {
          let shadowSize = CGSize(
              width:
                  self.drawingRenderViewSize.width +
                  DrawingViewController.kCanvasAbsentTouchShadowOverflow.width,
              height:
                  self.drawingRenderViewSize.height +
                  DrawingViewController.kCanvasAbsentTouchShadowOverflow.height)
          self.canvasShadowView.frame =
              CGRect(origin: CGPoint.zero, size: shadowSize)
          self.canvasShadowView.center = CGPoint(
              x:
                  self.canvasBackingView.center.x +
                  DrawingViewController.kCanvasAbsentTouchShadowOffset.x,
              y:
                  self.canvasBackingView.center.y +
                  DrawingViewController.kCanvasAbsentTouchShadowOffset.y)

          self.canvasBackingView.alpha = 1
          self.canvasShadowView.alpha =
              DrawingViewController.kCanvasAbsentTouchShadowOpacity
        },
        completion: nil)

    painterView.becomeFirstResponder()
  }


  override func viewDidDisappear(animated: Bool) {
    painterView.resignFirstResponder()
    
    canvasBackingView.alpha = 0
    canvasBackingView.layer.shadowOpacity = 0
    canvasBackingView.layer.shadowRadius = 0
    canvasBackingView.layer.shadowOffset = CGSizeZero

    super.viewDidDisappear(animated)
  }


  @objc private func handleTwoTouchTapGesture(
      twoTouchTapGesture: UITapGestureRecognizer) {
    self.drawingInteractionDelegate?.toggleTool()
  }


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
