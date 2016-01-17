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
  /// both the left and right side.
  /// left segments should connect points[i].left to points[i+1].left
  /// right segments should connect points[i+1].right to points[i].right
  var segmentPairs: [(left: ScaffoldSegment, right: ScaffoldSegment)] = []

  /// The segment capping the first scaffold point.
  /// The segment should connect points[0].b to points[0].a
  var startCapSegment: ScaffoldSegment?

  /// The segment capping the last scaffold point.
  /// The segment should connect points.last.a to points.last.b
  var endCapSegment: ScaffoldSegment?

  /// The segments within the scaffold ordered to create a path around the
  /// stroke.
  var segments: [ScaffoldSegment] {
    var list = segmentPairs.map { $0.left }
    if let endCap = endCapSegment {
      list.append(endCap)
    }
    list += segmentPairs.reverse().map { $0.right }
    if let startCap = startCapSegment {
      list.append(startCap)
    }
    return list
  }


  /**
   - returns: Whether the scaffold describes a completely enclosed stroke or
       not.
   */
  func doesDescribeCompleteStroke() -> Bool {
    let segmentCache = segments
    for i in 0..<segmentCache.count {
      let previousIndex = i > 0 ? i - 1 : segmentCache.count - 1
      if segmentCache[i].origin != segmentCache[previousIndex].terminal {
        return false
      }
    }

    return true
  }
}