//
//  ViewController.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingViewController: UIViewController, DrawingUpdateListener {
  // The default values for the brush and paint color.
  static let kDefaultBrush = CircularBrush(radius: 2)
  static let kDefaultPaintColor = UIColor.ballpointInkColor()

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
        brush: DrawingViewController.kDefaultBrush,
        paintColor: DrawingViewController.kDefaultPaintColor,
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
  }


  /// MARK: DrawingUpdateListener methods

  func drawingSnapshotUpdated(snapshot: UIImage) {
    drawingImageView.image = snapshot
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
