//
//  PointPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/21/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//


import CoreGraphics



struct PointPopulationStage: RenderPipelineStage {
  func process(inout scaffold: RenderScaffold, stroke: Stroke) {
    assert(
        stroke.points.count > 0,
        "Cannot populate scaffold points for an empty stroke.")

    let pointRadii = stroke.points.map {
      return
          ((stroke.maximumWidth - stroke.minimumWidth) * $0.sizeFactor +
           stroke.minimumWidth) / 2
    }

    for i in 0..<stroke.points.count {
      let previousPoint = i > 0 ? stroke.points[i - 1] : stroke.points[i]
      let nextPoint = i < stroke.points.count - 1 ?
          stroke.points[i + 1] :
          stroke.points[i]

      var tangentSlope: CGFloat
      if let slopeLine =
          Line(point: previousPoint.location, otherPoint: nextPoint.location) {
        tangentSlope = slopeLine.slope
      } else if let perpendicularLine = Line(
          point: stroke.points[i].location, otherPoint: nextPoint.location) {
        tangentSlope = -1 / perpendicularLine.slope
      } else {
        // If a tangent slope cannot be determined then supply an arbitrary
        // slope.
        tangentSlope = 0
      }

      scaffold.points.append(ScaffoldPoint(
          modelLocation: stroke.points[i].location,
          modelTangentLine: Line(
              slope: tangentSlope, throughPoint: stroke.points[i].location),
          radius: pointRadii[i]))
    }

    for i in 1..<scaffold.points.count {
      scaffold.points[i].ensurePointAlignment(scaffold.points[i - 1])
    }
  }
}