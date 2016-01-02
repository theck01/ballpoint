//
//  PointPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/21/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//


import CoreGraphics



struct PointPopulationStage: RenderPipelineStage {
  /// The radius of each point.
  private let REPLACE_ME: CGFloat = 1


  func process(inout scaffold: RenderScaffold, stroke: Stroke) {
    assert(
        stroke.points.count > 0,
        "Cannot populate scaffold points for an empty stroke.")

    // If the stroke only has one point supply an arbitrary tangent line.
    if stroke.points.count == 1 {
      scaffold.points.append(ScaffoldPoint(
          modelPoint: stroke.points[0],
          modelTangentLine:
              Line(slope: 0, throughPoint: stroke.points[0]),
          radius: REPLACE_ME))
      return
    }

    // Two consecutive points in a stroke are assumed to never be equal.
    let initialTangentLine = Line(
        point: stroke.points[0], otherPoint: stroke.points[1])!
    scaffold.points.append(ScaffoldPoint(
      modelPoint: stroke.points[0], modelTangentLine: initialTangentLine,
      radius: REPLACE_ME))

    for i in 1..<(stroke.points.count - 1) {
      var tangentSlope: CGFloat
      if let slopeLine = Line(
          point: stroke.points[i - 1], otherPoint: stroke.points[i + 1]) {
        tangentSlope = slopeLine.slope
      } else {
        // Two consecutive points in a stroke are assumed to never be equal.
        let perpendicularLine = Line(
            point: stroke.points[i], otherPoint: stroke.points[i + 1])!
        tangentSlope = -1 / perpendicularLine.slope
      }

      scaffold.points.append(ScaffoldPoint(
        modelPoint: stroke.points[i],
        modelTangentLine:
            Line(slope: tangentSlope, throughPoint: stroke.points[i]),
        radius: REPLACE_ME))
    }

    // Two consecutive points in a stroke are assumed to never be equal.
    let finalTangentLine = Line(
        point: stroke.points[stroke.points.count - 2],
        otherPoint: stroke.points.last!)!
    scaffold.points.append(ScaffoldPoint(
      modelPoint: stroke.points.last!, modelTangentLine: finalTangentLine,
      radius: REPLACE_ME))

    for i in 1..<scaffold.points.count {
      scaffold.points[i].ensurePointAlignment(scaffold.points[i - 1])
    }
  }
}