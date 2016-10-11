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
  fileprivate static let kNoTouchOpacity: CGFloat = 0
  fileprivate static let kTouchOpacity: CGFloat = 0.3

  // The action that is triggered when
  var pressAction: (() -> Void)?


  override init(frame: CGRect) {
    super.init(frame: frame)
    addTarget(
        self, action: #selector(onPress),
        for: UIControlEvents.touchUpInside)
    addTarget(
        self, action: #selector(onRelease),
        for:
            [UIControlEvents.touchUpInside, UIControlEvents.touchDragExit])
    addTarget(
        self, action: #selector(onDepress),
        for:
            [UIControlEvents.touchDown, UIControlEvents.touchDragEnter])
  }


  convenience init() {
    self.init(frame: CGRect.zero)
  }


  @objc fileprivate func onPress() {
    guard let action = pressAction else {
      return
    }
    action()
  }


  @objc fileprivate func onDepress() {
    backgroundColor = UIColor.ballpointDepressedButtonColor()
  }


  @objc fileprivate func onRelease() {
    backgroundColor = UIColor.clear
  }


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
