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
    let screenBounds = UIScreen.mainScreen().bounds
    drawingImageView = UIImageView(frame: screenBounds)
    pendingDrawingView = PendingDrawingView(frame: screenBounds)
    painterView = PainterView(
        brush: CircularBrush(radius: Constants.kPenBrushSize),
        paintColor: RendererColorPalette.defaultPalette[
            Constants.kBallpointInkColorId],
        frame: screenBounds)
    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = UIColor.whiteColor()
    drawingImageView.backgroundColor = UIColor.clearColor()
    pendingDrawingView.backgroundColor = UIColor.clearColor()
    painterView.backgroundColor = UIColor.clearColor()

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
    view.backgroundColor =
        palette[Constants.kBallpointSurfaceColorId].backingColor
  }


  /// MARK: UIViewController method overrides.

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    painterView.becomeFirstResponder()
  }
  
  override func viewDidDisappear(animated: Bool) {
    painterView.resignFirstResponder()
    super.viewDidDisappear(animated)
  }
  
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
