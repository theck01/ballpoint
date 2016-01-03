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

    // If the stroke only has one point supply an arbitrary tangent line.
    if stroke.points.count == 1 {
      scaffold.points.append(ScaffoldPoint(
          modelLocation: stroke.points[0].location,
          modelTangentLine:
              Line(slope: 0, throughPoint: stroke.points[0].location),
          radius: pointRadii[0]))
      return
    }

    // Two consecutive points in a stroke are assumed to never be equal.
    let initialTangentLine = Line(
        point: stroke.points[0].location,
        otherPoint: stroke.points[1].location)!
    scaffold.points.append(ScaffoldPoint(
        modelLocation: stroke.points[0].location,
        modelTangentLine: initialTangentLine,
        radius: pointRadii[0]))

    for i in 1..<(stroke.points.count - 1) {
      var tangentSlope: CGFloat
      if let slopeLine = Line(
          point: stroke.points[i - 1].location,
          otherPoint: stroke.points[i + 1].location) {
        tangentSlope = slopeLine.slope
      } else {
        // Two consecutive points in a stroke are assumed to never be equal.
        let perpendicularLine = Line(
            point: stroke.points[i].location,
            otherPoint: stroke.points[i + 1].location)!
        tangentSlope = -1 / perpendicularLine.slope
      }

      scaffold.points.append(ScaffoldPoint(
          modelLocation: stroke.points[i].location,
          modelTangentLine:
              Line(slope: tangentSlope, throughPoint: stroke.points[i].location),
          radius: pointRadii[i]))
    }

    // Two consecutive points in a stroke are assumed to never be equal.
    let finalTangentLine = Line(
        point: stroke.points[stroke.points.count - 2].location,
        otherPoint: stroke.points.last!.location)!
    scaffold.points.append(ScaffoldPoint(
        modelLocation: stroke.points.last!.location,
        modelTangentLine: finalTangentLine,
        radius: pointRadii.last!))

    for i in 1..<scaffold.points.count {
      scaffold.points[i].ensurePointAlignment(scaffold.points[i - 1])
    }
  }
}