//
//  AppDelegate.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import Foundation
import UIKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var drawingVC: DrawingViewController?

  /// The previous orientation of the device in radians. Initially infinity to
  /// indicate that the orientation is unknown.
  var previousOrientationAngle = CGFloat.infinity

  func application(
      application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) ->
          Bool {
    registerRendererColors()

    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    self.window = window
    window.backgroundColor = UIColor.whiteColor()

    let bounds = UIScreen.mainScreen().bounds
    let drawingSize = bounds.width < bounds.height ?
         CGSize(
            width: bounds.width - 2 * DrawingViewController.kCanvasMargin,
            height: bounds.height - 2 * DrawingViewController.kCanvasMargin) :
        CGSize(
            width: bounds.height - 2 * DrawingViewController.kCanvasMargin,
            height: bounds.width - 2 * DrawingViewController.kCanvasMargin)

    let drawingVC = DrawingViewController(drawingSize: drawingSize)
    self.drawingVC = drawingVC
    let renderer = DrawingRenderer(drawingSize: drawingSize)
    let model = DrawingModel(renderer: renderer)
    let controller = DrawingController(model: model, viewController: drawingVC)
    drawingVC.drawingInteractionDelegate = controller

    window.rootViewController = drawingVC
    window.makeKeyAndVisible()

    NSNotificationCenter.defaultCenter().addObserver(
        self, selector: "handleDeviceRotation",
        name: UIDeviceOrientationDidChangeNotification, object: nil)
    UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()

    return true
  }


  func handleDeviceRotation() {
    let device = UIDevice.currentDevice()
    if UIDeviceOrientationIsValidInterfaceOrientation(device.orientation) {
      let newAngle = device.deviceOrientationAngleOrDefault(0)
      if newAngle != previousOrientationAngle {
        drawingVC?.setDrawingContentRotation(newAngle)
        previousOrientationAngle = newAngle
      }
    }
  }


  private func registerRendererColors() {
    RendererColorPalette.defaultPalette.registerPalette([
      Constants.kBallpointInkColorId: UIColor.ballpointInkColor(),
      Constants.kBallpointSurfaceColorId: UIColor.ballpointSurfaceColor(),
    ])
  }
}

