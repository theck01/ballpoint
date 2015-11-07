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
  var points: [ScaffoldPoint] = []
  var segmentPairs: [(a: ScaffoldSegment, b: ScaffoldSegment)] = []
}