//
//  RendererStrokeScaffold.swift
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
  let modelTangentLine: Line
  private(set) var a: CGPoint
  private(set) var b: CGPoint


  init(modelLocation: CGPoint, modelTangentLine: Line, radius: CGFloat) {
    assert(
        Line.isPoint(modelLocation, onLine: modelTangentLine),
        "Cannot create a scaffold point from a model point that is not on " +
        "the associated tangent line")
    self.modelLocation = modelLocation
    self.modelTangentLine = modelTangentLine

    let perpendicularLine = Line.linePerpendicularToLine(
        modelTangentLine, throughPoint: modelLocation)
    (a, b) = Line.pointsAtDistance(
        radius, onLine: perpendicularLine, fromPoint: modelLocation)
  }


  mutating func ensurePointAlignment(previousPoint: ScaffoldPoint) {
    // TODO: Points may all be collinear or idendical, although those cases are
    // unlikely.
    if let aLine = Line(point: previousPoint.a, otherPoint: a) {
      if !Line.arePoints((previousPoint.b, b), onSameSideOfLine: aLine) {
        let temp = a
        a = b
        b = temp
      }
    } else if let bLine = Line(point: previousPoint.b, otherPoint: b) {
      if !Line.arePoints((previousPoint.a, a), onSameSideOfLine: bLine) {
        let temp = a
        a = b
        b = temp
      }
    }
  }
}
