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
    let sizeFactors = stroke.points.map { $0.sizeFactor }
    let filteredSizeFactors = averageFilterSizeFactors(
        sizeFactors,
        averageFilterWindowSize: PointPopulationStage.kAverageFilterWindowSize)
    return filteredSizeFactors.map {
      ((stroke.maximumWidth - stroke.minimumWidth) * $0 +
          stroke.minimumWidth) / 2
    }
  }
  

  /**
   - parameter sizeFactors:
   - parameter averageFilterWindowSIze:

   - returns: An array of size factors that has been average filtered with the
       given window.
   */
  private func averageFilterSizeFactors(
      sizeFactors: [CGFloat], averageFilterWindowSize: Int) -> [CGFloat] {
    var averageFilteredSizeFactors: [CGFloat] = []
    for i in 0..<sizeFactors.count {
      var sizeFactorSum: CGFloat = 0
      let averageFilterWindowStart = max(0, i - averageFilterWindowSize / 2)
      let averageFilterWindowEnd =
          min(sizeFactors.count - 1, i + averageFilterWindowSize / 2)
      for j in averageFilterWindowStart...averageFilterWindowEnd {
        sizeFactorSum += sizeFactors[j]
      }

      // Pad the sum with the central value in the window if fewer size factors
      // than the desired window size were used to prevent miss weighting those
      // factors.
      let windowSize = averageFilterWindowEnd - averageFilterWindowStart + 1
      sizeFactorSum +=
          CGFloat(averageFilterWindowSize - windowSize) * sizeFactors[i]

      averageFilteredSizeFactors.append(
          sizeFactorSum / CGFloat(averageFilterWindowSize))
    }

    return averageFilteredSizeFactors
  }
}