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
  
  var drawingVC: DrawingViewController?

  
  func application(
      application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) ->
          Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.whiteColor()
            
    drawingVC = DrawingViewController()
    window?.rootViewController = drawingVC
    window?.rootViewController?.view.backgroundColor =
          UIColor.launchScreenBackgroundColor()
            
    window?.makeKeyAndVisible()
            
    UIView.animateWithDuration(Constants.kAppLaunchedAnimationDuration) {
      self.window?.rootViewController?.view.backgroundColor =
          UIColor.whiteColor()
      return
    }
    return true
  }
}

