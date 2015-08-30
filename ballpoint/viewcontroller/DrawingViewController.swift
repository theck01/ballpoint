//
//  ViewController.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingViewController: UIViewController, ActionHandler {
  let drawingView: DrawingView

  init() {
    drawingView = DrawingView(frame: UIScreen.mainScreen().bounds)

    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(drawingView)

    drawingView.painter.actionHandler = self
  }
  

  /// MARK: ActionHandler methods

  func handleClearCanvas() {
    drawingView.clearStrokes()
  }


  func handleToolToggle() {
    println("Tool toggled!")
  }


  func handleUndo() {
    println("Undo!")
  }


  func handleRedo() {
    println("Redo!")
  }


  /// MARK: UIViewController method overrides.

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    drawingView.painter.becomeFirstResponder()
  }
  
  override func viewDidDisappear(animated: Bool) {
    drawingView.painter.resignFirstResponder()
    super.viewDidDisappear(animated)
  }
  
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
