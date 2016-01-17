//
//  RenderedStrokeScaffold.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// An object encapsulating all point information required for the scaffold.
/// This point wraps a modelLocation, grouping it with the tangent line to the
/// point and with additional points a and b that are used to connect
/// ScaffoldPoints.
struct ScaffoldPoint {
  let modelLocation: CGPoint
  let modelTangentLine: DirectedLine
  private(set) var left: CGPoint
  private(set) var right: CGPoint


  init(modelLocation: CGPoint, modelTangentLine: DirectedLine, radius: CGFloat) {
    assert(
        Line.isPoint(modelLocation, onLine: modelTangentLine.line),
        "Cannot create a scaffold point from a model point that is not on " +
        "the associated tangent line")
    self.modelLocation = modelLocation
    self.modelTangentLine = modelTangentLine

    let perpendicularLine = Line.linePerpendicularToLine(
        modelTangentLine.line, throughPoint: modelLocation)
    let (a, b) = Line.pointsAtDistance(
        radius, onLine: perpendicularLine, fromPoint: modelLocation)
    
    if DirectedLine.orientationOfPoint(a, toLine: modelTangentLine) ==
        DirectedLine.Orientation.Left {
      left = a
      right = b
    } else {
      left = b
      right = a
    }
  }
}
