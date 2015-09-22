//
//  DrawingInteractionDelegate.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/30/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//



/// Protocol for handling the results of user interactions.
protocol DrawingInteractionDelegate {
  /**
   Process the completion of the given stroke, which will no longer be updated.
   
   - parameter stroke:
   */
  func completeStrokes(strokes: [Stroke])

  /**
   Clear the drawing, presenting a blank canvas.
   */
  func clearDrawing()

  /**
   Toggle the current tool used to update the drawing, between pen and eraser.
   */
  func toggleTool()

  /**
   Undo the last edit to the drawing.
   */
  func undo()

  /**
   Redo the last undone edit to the drawing.
   */
  func redo()
}