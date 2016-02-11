//
//  ViewController.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics
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

  /// The root scroll view of the view hierarchy.
  let rootScrollView: UIScrollView

  /// The content container view of the view heirarchy.
  let contentContainerView: UIView

  /// The view of the canvas that provides a shadow.
  let canvasShadowView: UIView
  
  /// The backing view of the canvas.
  let canvasBackingView: UIView

  /// The view containing displayed drawings.
  let drawingContainerView: UIView

  /// The image view that displays the rendered drawing.
  let drawingImageView: UIImageView

  /// The view that displays pending drawing strokes.
  let pendingStrokeRenderer: StrokeRendererView

  /// The painter view that handles all user interaction.
  let painterView: PainterView

  /// The size of the view that renders the drawing in portrait orientation.
  private let drawingViewSize: CGSize

  /// The two touch tap recongizer that handles the tool change gesture.
  private let twoTouchTapRecognizer: UITapGestureRecognizer

  /// The state of painter touches are presence on screen.
  private enum PainterTouchPresence {
    case Present
    case Absent
    case Unknown
  }

  /// Whether touches are active on screen.
  private var painterTouchPresence = PainterTouchPresence.Unknown

  var drawingInteractionDelegate: DrawingInteractionDelegate? {
    get {
      return painterView.drawingInteractionDelegate
    }
    set {
      painterView.drawingInteractionDelegate = newValue
    }
  }


  /**
   - parameter drawingSize: The size of the drawing in portrait orientation.
   */
  init(drawingSize: CGSize) {
    rootScrollView = UIScrollView(frame: CGRect.zero)
    contentContainerView = UIView(frame: CGRect.zero)
    canvasShadowView = UIView(frame: CGRect.zero)
    canvasBackingView = UIView(frame: CGRect.zero)
    drawingContainerView = UIView(frame: CGRect.zero)
    drawingImageView = UIImageView(frame: CGRect.zero)
    pendingStrokeRenderer = StrokeRendererView(frame: CGRect.zero)
    painterView = PainterView(
        brush: Constants.kPenBrush,
        paintColor:
            RendererColorPalette.defaultPalette[Constants.kBallpointInkColorId],
        frame: CGRect.zero)
    drawingViewSize = drawingSize
    twoTouchTapRecognizer = UITapGestureRecognizer()

    super.init(nibName: nil, bundle: nil)

    self.view.addSubview(rootScrollView)
    rootScrollView.addSubview(contentContainerView)
    contentContainerView.addSubview(canvasShadowView)
    contentContainerView.addSubview(canvasBackingView)
    contentContainerView.addSubview(drawingContainerView)
    drawingContainerView.addSubview(drawingImageView)
    drawingContainerView.addSubview(pendingStrokeRenderer)
    drawingContainerView.addSubview(painterView)

    rootScrollView.backgroundColor = UIColor.launchScreenBackgroundColor()
    contentContainerView.backgroundColor = UIColor.launchScreenBackgroundColor()
    canvasShadowView.backgroundColor = UIColor.darkGrayColor()
    canvasBackingView.backgroundColor = RendererColorPalette.defaultPalette[
        Constants.kBallpointSurfaceColorId].backingColor
    drawingContainerView.backgroundColor = UIColor.clearColor()
    drawingImageView.backgroundColor = UIColor.clearColor()
    pendingStrokeRenderer.backgroundColor = UIColor.clearColor()
    painterView.backgroundColor = UIColor.clearColor()

    rootScrollView.alwaysBounceHorizontal = true
    rootScrollView.alwaysBounceVertical = true
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


  /**
   Updates drawing rotation.
   
   - parameter rotation: The rotation angle for the drawing content, in radians.
   */
  func setDrawingContentRotation(rotation: CGFloat) {
    drawingContainerView.transform = CGAffineTransformMakeRotation(rotation)
    // Request a layout to properly position rotated view.
    view.setNeedsLayout()
  }


  /// MARK: PainterTouchDelegate methods

  func painterTouchesActive() {
    painterTouchPresence = PainterTouchPresence.Present
    UIView.animateWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        delay: 0,
        options: [
            UIViewAnimationOptions.BeginFromCurrentState,
            UIViewAnimationOptions.CurveEaseOut],
        animations: {
          self.updateShadowForPainterTouchPresence()
        },
        completion: nil)
  }


  func painterTouchesAbsent() {
    painterTouchPresence = PainterTouchPresence.Absent
    UIView.animateWithDuration(
        DrawingViewController.kPainterTouchesActiveAnimationDuration,
        delay: 0,
        options: [
            UIViewAnimationOptions.BeginFromCurrentState,
            UIViewAnimationOptions.CurveEaseOut],
        animations: {
          self.updateShadowForPainterTouchPresence()
        },
        completion: nil)
  }


  private func updateShadowForPainterTouchPresence() {
    var overflow = CGSize.zero
    var offset = CGPoint.zero
    var alpha = canvasShadowView.alpha
    switch(painterTouchPresence) {
      case PainterTouchPresence.Present:
        overflow = DrawingViewController.kCanvasActiveTouchShadowOverflow
        offset = DrawingViewController.kCanvasActiveTouchShadowOffset
        alpha = DrawingViewController.kCanvasActiveTouchShadowOpacity
      case PainterTouchPresence.Absent:
        overflow = DrawingViewController.kCanvasAbsentTouchShadowOverflow
        offset = DrawingViewController.kCanvasAbsentTouchShadowOffset
        alpha = DrawingViewController.kCanvasAbsentTouchShadowOpacity
      default:
        break
    }

    let shadowSize = CGSize(
        width: self.canvasBackingView.bounds.width + overflow.width,
        height: self.canvasBackingView.bounds.height + overflow.height)
    self.canvasShadowView.frame =
        CGRect(origin: CGPoint.zero, size: shadowSize)
    self.canvasShadowView.center = CGPoint(
        x: self.canvasBackingView.center.x + offset.x,
        y: self.canvasBackingView.center.y + offset.y)
    self.canvasShadowView.alpha = alpha
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

  override func viewDidLayoutSubviews() {
    let canvasFrame = view.bounds.width > view.bounds.height ?
        CGRect(
          origin: CGPoint(
              x: DrawingViewController.kCanvasMargin,
              y: DrawingViewController.kCanvasMargin),
          size: CGSize(
              width: drawingViewSize.height,
              height: drawingViewSize.width)) :
        CGRect(
          origin: CGPoint(
              x: DrawingViewController.kCanvasMargin,
              y: DrawingViewController.kCanvasMargin),
          size: drawingViewSize)
    let drawingFrame = CGRect(origin: CGPoint.zero, size: drawingViewSize)

    rootScrollView.frame = view.bounds
    rootScrollView.contentSize = view.bounds.size
    contentContainerView.frame = view.bounds
    canvasBackingView.frame = canvasFrame
    // Update shadow frame, after backing view has been set to ensure proper
    // shadow sizing.
    updateShadowForPainterTouchPresence()
    drawingContainerView.frame = canvasFrame
    drawingImageView.frame = drawingFrame
    pendingStrokeRenderer.frame = drawingFrame
    painterView.frame = drawingFrame
  }


  override func viewWillTransitionToSize(
      size: CGSize,
      withTransitionCoordinator coordinator:
          UIViewControllerTransitionCoordinator) {
    // Disable view animations during transitions to a new size. Specifically
    // this blocks animations due to screen rotations.
    UIView.setAnimationsEnabled(false)
    coordinator.animateAlongsideTransition(nil) {
        (context: UIViewControllerTransitionCoordinatorContext) in
      UIView.setAnimationsEnabled(true)
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    painterTouchPresence = PainterTouchPresence.Absent
    UIView.animateWithDuration(
        DrawingViewController.kCanvasRaiseAnimationDuration,
        delay: 0,
        options: UIViewAnimationOptions.CurveEaseOut,
        animations: {
          self.updateShadowForPainterTouchPresence()
          self.canvasBackingView.alpha = 1
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
