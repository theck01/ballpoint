//
//  DrawingControllerViewDelegate.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/11/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//

import UIKit


/**
 Delegate that handles updating the view in response to controller changes.
 */
protocol DrawingControllerViewDelegate {
  var painterView: PainterView { get }

  func updateDrawingSnapshot(_ snapshot: UIImage)
}
