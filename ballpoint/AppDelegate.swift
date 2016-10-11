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
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) ->
          Bool {
    registerRendererColors()

    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    window.backgroundColor = UIColor.white

    let bounds = UIScreen.main.bounds
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

    NotificationCenter.default.addObserver(
        self, selector: #selector(handleDeviceRotation),
        name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()

    return true
  }


  func handleDeviceRotation() {
    let device = UIDevice.current
    if UIDeviceOrientationIsValidInterfaceOrientation(device.orientation) {
      let newAngle = device.deviceOrientationAngleOrDefault(0)
      if newAngle != previousOrientationAngle {
        drawingVC?.setDrawingContentRotation(
            newAngle, previousRotation: previousOrientationAngle)
        previousOrientationAngle = newAngle
      }
    }
  }


  fileprivate func registerRendererColors() {
    RendererColorPalette.defaultPalette.registerPalette([
      Constants.kBallpointInkColorId: UIColor.ballpointInkColor(),
      Constants.kBallpointSurfaceColorId: UIColor.ballpointSurfaceColor(),
    ])
  }
}

