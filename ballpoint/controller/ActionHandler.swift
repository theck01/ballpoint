//
//  ActionHandler.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//



protocol ActionHandler {
  func handleClearCanvas()

  func handleToolToggle()

  func handleUndo()

  func handleRedo()
}