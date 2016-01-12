//
//  SegmentPopulationStage.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/24/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// Creates render segments between all existing render points within a
/// scaffold.
struct SegmentPopulationStage: RenderPipelineStage {
  func process(inout scaffold: RenderScaffold, stroke: Stroke) {
    if scaffold.points.count < 3 {
      return
    }
    
    for i in 1..<(scaffold.points.count - 1) {
      let previousPoint = scaffold.points[i - 1]
      let currentPoint = scaffold.points[i]
      let nextPoint: ScaffoldPoint = scaffold.points[i + 1]

      let segmentA = createQuadraticSegmentConnector(
          previousPoint.a, b: currentPoint.a, c: nextPoint.a)
      let segmentB = createQuadraticSegmentConnector(
          nextPoint.b, b: currentPoint.b, c: previousPoint.b)

      scaffold.segmentPairs.append((a: segmentA, b: segmentB))
    }
  }


  /**
   - parameter a: The first point in the sequence to connect.
   - parameter b: The middle point in the sequence to connect.
   - parameter c: The final point in the sequence to connect.

   - returns: The scaffold segment that connects the midpoint of ab to the
       midpoint of bc.
   */
  private func createQuadraticSegmentConnector(
      a: CGPoint, b: CGPoint, c: CGPoint) -> ScaffoldSegment {
    var midpointAB = a
    if let segmentAB = LineSegment(point: a, otherPoint: b) {
      midpointAB = LineSegment.midpoint(segmentAB)
    }
    var midpointBC = c
    if let segmentBC = LineSegment(point: b, otherPoint: c) {
      midpointBC = LineSegment.midpoint(segmentBC)
    }

    return QuadraticBezierScaffoldSegment(
        origin: midpointAB, terminal: midpointBC, controlPoint: b)
  }
}
