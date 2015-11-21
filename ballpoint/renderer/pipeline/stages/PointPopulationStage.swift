//
//  PointPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/21/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//


import CoreGraphics



class PointPopulationStage: RenderPipelineStage {
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
          tangentLine:
              Line(slope: 0, throughPoint: stroke.points[0]),
          radius: REPLACE_ME))
      return
    }

    scaffold.points.append(ScaffoldPoint(
      modelPoint: stroke.points[0],
      tangentLine: Line(point: stroke.points[0], otherPoint: stroke.points[1]),
      radius: REPLACE_ME))

    for i in 1..<(stroke.points.count - 1) {
      let slopeLine = Line(
          point: stroke.points[i - 1], otherPoint: stroke.points[i + 1])
      scaffold.points.append(ScaffoldPoint(
        modelPoint: stroke.points[i],
        tangentLine:
            Line(slope: slopeLine.slope, throughPoint: stroke.points[i]),
        radius: REPLACE_ME))
    }

    scaffold.points.append(ScaffoldPoint(
      modelPoint: stroke.points.last!,
      tangentLine: Line(
          point: stroke.points[stroke.points.count - 2],
          otherPoint: stroke.points.last!),
      radius: REPLACE_ME))

    for i in 1..<scaffold.points.count {
      scaffold.points[i].ensurePointAlignment(scaffold.points[i - 1])
    }
  }
}