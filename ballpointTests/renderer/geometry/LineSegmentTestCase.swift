//
//  LineSegmentTestCase.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/25/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import XCTest

import ballpoint



class LineSegmentTestCase: XCTestCase {
  // Verifes that isPoint:onLineSegment: works.
  func testIsPointOnLineSegment() {
    let segment = LineSegment(
        point: CGPointZero, otherPoint: CGPoint(x: 5, y: 5))

    var point = CGPoint(x: 2, y: 2)
    XCTAssertTrue(LineSegment.isPoint(point, onLineSegment: segment))

    point = CGPoint(x: 0, y: 2)
    XCTAssertFalse(LineSegment.isPoint(point, onLineSegment: segment))

    point = CGPoint(x: 10, y: 10)
    XCTAssertFalse(LineSegment.isPoint(point, onLineSegment: segment))
  }
}