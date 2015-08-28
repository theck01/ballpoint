//
//  ViewController.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



class DrawingViewController: UIViewController {
  var drawingView: DrawingView
  
  
  init() {
    drawingView = DrawingView(frame: UIScreen.mainScreen().bounds)
    
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = UIColor.whiteColor()
    
    view.addSubview(drawingView)
  }
  
  
  func clearView() {
    drawingView.removeFromSuperview()
    drawingView = DrawingView(frame: UIScreen.mainScreen().bounds)
    view.addSubview(drawingView)
  }
  
  
  override func canBecomeFirstResponder() -> Bool {
    return true
  }


  override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
    if motion == UIEventSubtype.MotionShake {
      clearView()
    }
  }
  
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    becomeFirstResponder()
  }
  
  override func viewDidDisappear(animated: Bool) {
    resignFirstResponder()
    super.viewDidDisappear(animated)
  }
  
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
