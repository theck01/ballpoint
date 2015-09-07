//
//  AppDelegate.swift
//  inkwell
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
      application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) ->
          Bool {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    self.window = window
    window.backgroundColor = UIColor.whiteColor()

    let renderer = DrawingRenderer()

    let model = DrawingModel(renderer: renderer)

    let controller = DrawingController(model: model)

    let drawingVC = DrawingViewController()
    drawingVC.drawingInteractionDelegate = controller
    drawingVC.view.backgroundColor = UIColor.launchScreenBackgroundColor()

    model.registerDrawingUpdateListener(drawingVC)

    window.rootViewController = drawingVC
    window.makeKeyAndVisible()
            
    UIView.animateWithDuration(Constants.kAppLaunchedAnimationDuration) {
      drawingVC.view.backgroundColor = UIColor.whiteColor()
    }

    return true
  }
}

