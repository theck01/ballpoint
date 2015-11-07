//
//  RendererStrokeScaffold.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



struct RendererScaffold {
  // A point within the RendererScaffold. This point wraps a modelPoint,
  // grouping it with the tangent line to the point and with additional points
  // a and b that are used to connect Point instances.
  struct Point {
    let modelPoint: CGPoint
    let tangentLine: Line
    private(set) var a: CGPoint
    private(set) var b: CGPoint


    init(modelPoint: CGPoint, tangentLine: Line, radius: CGFloat) {
      assert(
          Line.isPoint(modelPoint, onLine: tangentLine),
          "Cannot create a scaffold point from a model point that is not on " +
          "the associated tangent line")
      self.modelPoint = modelPoint
      self.tangentLine = tangentLine

      let perpendicularLine = Line.linePerpendicularToLine(
          tangentLine, throughPoint: modelPoint)
      (a, b) = Line.pointsAtDistance(
          radius, onLine: perpendicularLine, fromPoint: modelPoint)
    }


    mutating func ensurePointAlignment(previousPoint: Point) {
      // TODO: Points may all be collinear, although that case is unlikely.
      let aLine = Line(point: previousPoint.a, otherPoint: a)
      if !Line.arePoints((previousPoint.b, b), onSameSideOfLine: aLine) {
        let temp = a
        a = b
        b = temp
      }
    }
  }
}