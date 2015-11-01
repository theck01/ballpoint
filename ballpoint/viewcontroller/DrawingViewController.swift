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
  // The constants describing the shadow behind the canvas backing.
  static let kCanvasAbsentTouchShadowOpacity: CGFloat = 0.6
  static let kCanvasAbsentTouchShadowRadius: CGFloat =
      Constants.kCanvasScreenSeparation / 2
  static let kCanvasAbsentTouchShadowYOffset: CGFloat = 0
  static let kCanvasActiveTouchShadowOpacity: CGFloat =
      DrawingViewController.kCanvasAbsentTouchShadowOpacity / 2
  static let kCanvasActiveTouchShadowRadius: CGFloat =
      DrawingViewController.kCanvasAbsentTouchShadowRadius / 2
  static let kCanvasActiveTouchShadowYOffset: CGFloat = 0
  
  /// The duration of the shadow animation when painter touches are active.
  static let kPainterTouchesActiveAnimationDuration: NSTimeInterval = 0.16

  // The minimum and maximum values for the zoom level of the root UIScrollView.
  static let kMaximumZoomLevel: CGFloat = 5
  static let kMinimumZoomLevel: CGFloat = 1

  /// The root scroll view of the view hierarchy.
  let rootScrollView: UIScrollView

  /// The content container view of the view heirarchy.
  let contentContainerView: UIView
  
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
    let canvasFrame = CGRect(
        origin: CGPoint(
            x: Constants.kCanvasScreenSeparation,
            y: Constants.kCanvasScreenSeparation),
        size: Constants.kDrawingSize)

    rootScrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    contentContainerView = UIView(frame: UIScreen.mainScreen().bounds)
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

    rootScrollView.backgroundColor = UIColor.launchScreenBackgroundColor()
    contentContainerView.backgroundColor = UIColor.launchScreenBackgroundColor()
    canvasBackingView.backgroundColor = RendererColorPalette.defaultPalette[
        Constants.kBallpointSurfaceColorId].backingColor
    drawingImageView.backgroundColor = UIColor.clearColor()
    pendingStrokeRenderer.backgroundColor = UIColor.clearColor()
    painterView.backgroundColor = UIColor.clearColor()

    canvasBackingView.alpha = 0
    drawingImageView.alpha = 0
    pendingStrokeRenderer.alpha = 0

    rootScrollView.addSubview(contentContainerView)
    contentContainerView.addSubview(canvasBackingView)
    contentContainerView.addSubview(drawingImageView)
    contentContainerView.addSubview(pendingStrokeRenderer)
    contentContainerView.addSubview(painterView)

    rootScrollView.alwaysBounceHorizontal = true
    rootScrollView.alwaysBounceVertical = true
    rootScrollView.contentSize = rootScrollView.bounds.size
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


  @objc private func handleTwoTouchTapGesture(
      twoTouchTapGesture: UITapGestureRecognizer) {
    self.drawingInteractionDelegate?.toggleTool()
  }


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
