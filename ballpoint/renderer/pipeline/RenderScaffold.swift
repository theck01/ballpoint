//
//  RenderScaffold.swift
//  ballpoint
//
//  Created by Tyler Heck on 11/7/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//



/// A scaffold containing data required to generating a CGPath from a model
/// Stroke.
struct RenderScaffold {
  /// The scaffold points that make up the stroke.
  var points: [ScaffoldPoint] = []

  /// The segments that describe the boundary of the stroke. segmentPair[i]
  /// should describe the boundary connecting points[i] to points[i+1], on
  /// both the a and b side.
  /// a segments should connect points[i].a to points[i+1].a
  /// b segments should connect points[i+1].b to points[i].b
  var segmentPairs: [(a: ScaffoldSegment, b: ScaffoldSegment)] = []

  /// The segment capping the first scaffold point.
  /// The segment should connect points[0].b to points[0].a
  var startCapSegment: ScaffoldSegment?

  /// The segment capping the last scaffold point.
  /// The segment should connect points.last.a to points.last.b
  var endCapSegment: ScaffoldSegment?

  /// The segments within the scaffold ordered to create a path around the
  /// stroke.
  var segments: [ScaffoldSegment] {
    var list = segmentPairs.map { $0.a }
    if let endCap = endCapSegment {
      list.append(endCap)
    }
    list += segmentPairs.reverse().map { $0.b }
    if let startCap = startCapSegment {
      list.append(startCap)
    }
    return list
  }

  /// Whether the scaffold describes a completely enclosed stroke or not.
  var doesDescribeCompleteStroke: Bool {
    if segmentPairs.count != points.count - 1 {
      return false
    }

    for i in 0..<segmentPairs.count {
      let origin = points[i]
      let terminal = points[i+1]
      let aSegment = segmentPairs[i].a
      let bSegment = segmentPairs[i].b

      if aSegment.origin != origin.a || aSegment.terminal != terminal.a ||
          bSegment.origin != terminal.b || bSegment.terminal != origin.b {
        return false
      }
    }

    guard let startCap = startCapSegment else {
      return false
    }
    if startCap.origin != points[0].b || startCap.terminal != points[0].a {
      return false
    }

    guard let endCap = endCapSegment else {
      return false
    }
    if endCap.origin != points.last!.a || endCap.terminal != points.last!.b {
      return false
    }

    return true
  }
}