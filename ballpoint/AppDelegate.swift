//
//  AppDelegate.swift
//  ballpoint
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
    registerRendererColors()

    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    self.window = window
    window.backgroundColor = UIColor.whiteColor()

    let drawingVC = DrawingViewController()
    let renderer = DrawingRenderer(drawingSize: drawingVC.drawingRenderViewSize)
    let model = DrawingModel(renderer: renderer)
    let controller = DrawingController(model: model, viewController: drawingVC)
    drawingVC.drawingInteractionDelegate = controller

    window.rootViewController = drawingVC
    window.makeKeyAndVisible()
            
    return true
  }


  private func registerRendererColors() {
    RendererColorPalette.defaultPalette.registerPalette([
      Constants.kBallpointInkColorId: UIColor.ballpointInkColor(),
      Constants.kBallpointSurfaceColorId: UIColor.ballpointSurfaceColor(),
    ])
  }
}

