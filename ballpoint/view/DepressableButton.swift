//
//  DepressableButton.swift
//  ballpoint
//
//  Created by Tyler Heck on 4/24/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//

import UIKit


/// A button-like view that changes background opacity based on touch state
/// and triggers an action when a press is processed.
class DepressableButton: UIButton {
  private static let kNoTouchOpacity: CGFloat = 0
  private static let kTouchOpacity: CGFloat = 0.3

  // The action that is triggered when
  var pressAction: (() -> Void)?


  override init(frame: CGRect) {
    super.init(frame: frame)
    addTarget(
        self, action: #selector(onPress),
        forControlEvents: UIControlEvents.TouchUpInside)
    addTarget(
        self, action: #selector(onRelease),
        forControlEvents:
            [UIControlEvents.TouchUpInside, UIControlEvents.TouchDragExit])
    addTarget(
        self, action: #selector(onDepress),
        forControlEvents:
            [UIControlEvents.TouchDown, UIControlEvents.TouchDragEnter])
  }


  convenience init() {
    self.init(frame: CGRect.zero)
  }


  @objc private func onPress() {
    guard let action = pressAction else {
      return
    }
    action()
  }


  @objc private func onDepress() {
    backgroundColor = UIColor.ballpointDepressedButtonColor()
  }


  @objc private func onRelease() {
    backgroundColor = UIColor.clearColor()
  }


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
