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
  fileprivate static let kCGPointInf = CGPoint(
      x: CGFloat.infinity, y: CGFloat.infinity)

  // Verify that constructing a segment with identical points generates a nil
  // value.
  func testIdenticalPointsGenerateNil() {
    let segment = LineSegment(point: CGPoint.zero, otherPoint: CGPoint.zero)
    XCTAssertNil(
        segment, "Expected identical points to generate a nil segment.")
  }

  // Verifes that isPoint:onLineSegment: works.
  func testIsPointOnLineSegment() {
    let segment = LineSegment(
        point: CGPoint.zero, otherPoint: CGPoint(x: 5, y: 5))!
    let horizontalSegment = LineSegment(
        point: CGPoint(x: 0, y: 2), otherPoint: CGPoint(x: 1, y: 2))!

    var point = CGPoint(x: 2, y: 2)
    XCTAssertTrue(LineSegment.isPoint(point, onLineSegment: segment))
    XCTAssertFalse(LineSegment.isPoint(point, onLineSegment: horizontalSegment))

    point = CGPoint(x: 0, y: 2)
    XCTAssertFalse(LineSegment.isPoint(point, onLineSegment: segment))
    XCTAssertTrue(LineSegment.isPoint(point, onLineSegment: horizontalSegment))

    point = CGPoint(x: 10, y: 10)
    XCTAssertFalse(LineSegment.isPoint(point, onLineSegment: segment))
    XCTAssertFalse(LineSegment.isPoint(point, onLineSegment: horizontalSegment))
  }


  // Verifies that intersection works.
  func testIntersection() {
    let inclinedSegment = LineSegment(
        point: CGPoint.zero, otherPoint: CGPoint(x: 5, y: 5))!
    let verticalSegment = LineSegment(
        point: CGPoint.zero, otherPoint: CGPoint(x: 0, y: 5))!
    let horizontalSegment = LineSegment(
        point: CGPoint(x: 2, y: 2), otherPoint: CGPoint(x: 5, y: 2))!
    
    var expectedIntersection = CGPoint.zero
    var actualIntersection = LineSegment.intersection(
        inclinedSegment, verticalSegment)
    XCTAssertNotNil(actualIntersection)
    XCTAssertTrue(
        expectedIntersection =~=
        (actualIntersection ?? LineSegmentTestCase.kCGPointInf))

    expectedIntersection = CGPoint(x: 2, y: 2)
    actualIntersection = LineSegment.intersection(
        inclinedSegment, horizontalSegment)
    XCTAssertNotNil(actualIntersection)
    XCTAssertTrue(
        expectedIntersection =~=
        (actualIntersection ?? LineSegmentTestCase.kCGPointInf))

    actualIntersection = LineSegment.intersection(
        verticalSegment, horizontalSegment)
    XCTAssertNil(actualIntersection)
  }


  // Verifies that midpoint works
  func testMidpoint() {
    let segment = LineSegment(
        point: CGPoint(x: -4, y: 4), otherPoint: CGPoint(x: 4, y: -4))!
    let expectedMidpoint = CGPoint.zero
    XCTAssertTrue(LineSegment.midpoint(segment) =~= expectedMidpoint)
  }
}
