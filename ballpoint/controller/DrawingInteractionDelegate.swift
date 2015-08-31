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
   Process the update of a pending strokes, which may be updated in the future.

   :param: stroke
  */
  func updatePendingStroke(stroke: Stroke)

  /**
   Process the cancellation of all pending strokes.
   */
  func cancelPendingStrokes()

  /**
   Process the completion of the given stroke, which will no longer be updated.
   
   :param: stroke
   */
  func completeStroke(stroke: Stroke)

  /**
   Clear the drawing, presenting a blank canvas.
   */
  func clearDrawing()

  /**
   Toggle the current tool used to update the drawing, between pen and eraser.
   */
  func toggleTool()
}