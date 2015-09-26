//
//  UndoDirectionController.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/7/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// Class responsible for calling one of two actions based upon a given
/// direction. A direction is supplied for a primary action, with the secondary
/// action being associated with the opposite direction.
class DirectedActionController {
  /// The closure to call to trigger the primary action.
  private let primaryAction: () -> ()

  /// The closure to call to trigger the secondary action.
  private let secondaryAction: () -> ()

  /// The vector pointing in the direction that most strongly correlates to the
  /// primary action. If a direction is not set when an action is requested to
  /// be triggered then the primary action is fired and the direction that
  /// was provided with the trigger will be associated with the primary action.
  private var primaryActionDirection: CGVector?


  init(
      primaryAction: () -> (), secondaryAction: () -> ()) {
    self.primaryAction = primaryAction
    self.secondaryAction = secondaryAction
  }


  func clearDirectionAssociations() {
    primaryActionDirection = nil
  }


  func triggerActionForDirection(direction: CGVector) {
    if let primaryDirection = primaryActionDirection {
      let angleDifference = primaryDirection.angleBetweenVector(direction)
      
      if angleDifference < 45 {
        primaryAction()
      } else if abs(angleDifference - 180) < 45 {
        secondaryAction()
      }
    } else {
      primaryActionDirection = direction
      primaryAction()
    }
  }
}
