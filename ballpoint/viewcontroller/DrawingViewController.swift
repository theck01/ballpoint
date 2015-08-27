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
  
  
  @objc func clearView() {
    drawingView.removeFromSuperview()
    drawingView = DrawingView(frame: UIScreen.mainScreen().bounds)
    view.addSubview(drawingView)
  }
  
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
