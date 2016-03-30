//
//  PointPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/21/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//


import CoreGraphics



struct PointPopulationStage: RenderPipelineStage {
  /// The number of points to include in the averaging filter's window.
  private static let kAverageFilterWindowSize = 5


  func process(inout scaffold: RenderScaffold, stroke: Stroke) {
    assert(
        stroke.points.count > 0,
        "Cannot populate scaffold points for an empty stroke.")

    let pointRadii = stroke.points.map { $0.radius }
    for i in 0..<stroke.points.count {
      let previousPoint = i > 0 ? stroke.points[i - 1] : stroke.points[i]
      let nextPoint = i < stroke.points.count - 1 ?
          stroke.points[i + 1] :
          stroke.points[i]

      var tangentSlope: CGFloat
      var direction: CGVector
      if let slopeLine =
          Line(point: previousPoint.location, otherPoint: nextPoint.location) {
        tangentSlope = slopeLine.slope
        direction = CGVector(
            dx: nextPoint.location.x - previousPoint.location.x,
            dy: nextPoint.location.y - previousPoint.location.y)
      } else if let perpendicularLine = Line(
          point: stroke.points[i].location, otherPoint: nextPoint.location) {
        tangentSlope = -1 / perpendicularLine.slope
        direction = CGVector(
            dx: nextPoint.location.x - stroke.points[i].location.x,
            dy: nextPoint.location.y - stroke.points[i].location.y)
      } else {
        // If a tangent slope cannot be determined then supply an arbitrary
        // slope and direction.
        tangentSlope = 0
        direction = CGVector(dx: 1, dy: 0)
      }

      let tangentLine = Line(
          slope: tangentSlope, throughPoint: stroke.points[i].location)

      scaffold.points.append(ScaffoldPoint(
          modelLocation: stroke.points[i].location,
          modelTangentLine:
              DirectedLine(line: tangentLine, direction: direction),
          radius: pointRadii[i]))
    }
  }


  /**
   - parameter stroke:

   - returns: The array of point radii that should be used for each
       scaffold point.
   */
  private func calculatePointRadii(stroke: Stroke) -> [CGFloat] {
    let radii = stroke.points.map { $0.radius }
    return averageFilter(
      radii, windowSize: PointPopulationStage.kAverageFilterWindowSize)
  }
  

  /**
   - parameter sizeFactors:
   - parameter averageFilterWindowSIze:

   - returns: An array of size factors that has been average filtered with the
       given window.
   */
  private func averageFilter(
      floats: [CGFloat], windowSize: Int) -> [CGFloat] {
    var averageFilteredFloats: [CGFloat] = []
    for i in 0..<floats.count {
      var sum: CGFloat = 0
      let windowStart = max(0, i - windowSize / 2)
      let windowEnd = min(floats.count - 1, i + windowSize / 2)
      for j in windowStart...windowEnd {
        sum += floats[j]
      }

      // Pad the sum with the central value in the window if fewer size factors
      // than the desired window size were used to prevent miss weighting those
      // factors.
      let includedFloatCount = windowEnd - windowStart + 1
      sum += CGFloat(windowSize - includedFloatCount) * floats[i]

      averageFilteredFloats.append(sum / CGFloat(windowSize))
    }

    return averageFilteredFloats
  }
}