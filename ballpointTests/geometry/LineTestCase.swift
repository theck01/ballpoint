//
//  LineTestCase.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/18/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import XCTest

import ballpoint



class LineTestCase: XCTestCase {
  // Verify that Line#isPoint:onLine: works for a non-vertical and
  // non-horizontal line.
  func testIsPointOnLine() {
    let line = Line(point: CGPointZero, otherPoint: CGPoint(x: 1, y: 1))
    XCTAssertTrue(
        Line.isPoint(CGPointZero, onLine: line),
        "Point used to construct line should be considered on the line")
    XCTAssertTrue(
        Line.isPoint(CGPoint(x: 5, y: 5.00000000000000000001), onLine: line),
        "Point that is an insignificant fraction away from the line should " +
        "considered on the line.")
    XCTAssertFalse(
        Line.isPoint(CGPoint(x: 5, y: 6), onLine: line),
        "Point that is an significant distance away from the line should " +
        "considered off the line.")
  }


  // Verify that Line#isPoint:onLine: works for a vertical line.
  func testIsPointOnLine_verticalLine() {
    let line = Line(point: CGPointZero, otherPoint: CGPoint(x: 0, y: 1))
    XCTAssertTrue(
        Line.isPoint(CGPointZero, onLine: line),
        "Point used to construct line should be considered on the line")
    XCTAssertTrue(
        Line.isPoint(CGPoint(x: 0, y: 5.00000000000000000001), onLine: line),
        "Point that is an insignificant fraction away from the line should " +
        "considered on the line.")
    XCTAssertFalse(
        Line.isPoint(CGPoint(x: 5, y: 6), onLine: line),
        "Point that is an significant distance away from the line should " +
        "considered off the line.")
  }


  // Verify that Line#intersection works.
  func testIntersection() {
    let verticalLine = Line(
        point: CGPoint(x: 1, y: 1), otherPoint: CGPoint(x: 1, y: 2))
    let horizontalLine = Line(
        point: CGPoint(x: 0, y: 10), otherPoint: CGPoint(x: 1, y: 10))
    let line = Line(
        point: CGPoint(x: 2, y: 5), otherPoint: CGPoint(x: 3, y: 6))
    let steepLine = Line(
        point: CGPoint(x: 0, y: 9), otherPoint: CGPoint(x: 1, y: 7))
    let parallelLine = Line(
        point: CGPoint(x: 0, y: 0), otherPoint: CGPoint(x: 1, y: 1))

    var expectedIntersection = CGPoint(x: 1, y: 10)
    var actualIntersection = Line.intersection(verticalLine, horizontalLine)
    XCTAssertTrue(
        actualIntersection != nil &&
        actualIntersection! =~= expectedIntersection)

    expectedIntersection = CGPoint(x: 2, y: 5)
    actualIntersection = Line.intersection(steepLine, line)
    XCTAssertTrue(
        actualIntersection != nil &&
        actualIntersection! =~= expectedIntersection)

    expectedIntersection = CGPoint(x: 1, y: 4)
    actualIntersection = Line.intersection(verticalLine, line)
    XCTAssertTrue(
        actualIntersection != nil &&
        actualIntersection! =~= expectedIntersection)

    expectedIntersection = CGPoint(x: -0.5, y: 10)
    actualIntersection = Line.intersection(steepLine, horizontalLine)
    XCTAssertTrue(
        actualIntersection != nil &&
        actualIntersection! =~= expectedIntersection)

    XCTAssertNil(Line.intersection(line, parallelLine))
  }


  // Verify that pointsAtDistance:onLine:fromPoint works.
  func testPointsAtDistanceOnLineFromPoint() {
    let line = Line(point: CGPointZero, otherPoint: CGPoint(x: 1, y: 1))
    let point = CGPoint(x: 5, y: 5)
    let expectedPointA = CGPoint(x: 6, y: 6)
    let expectedPointB = CGPoint(x: 4, y: 4)

    let (actualPointA, actualPointB) = Line.pointsAtDistance(
        sqrt(2), onLine: line, fromPoint: point)
    XCTAssertTrue(
        actualPointA =~= expectedPointA || actualPointA =~= expectedPointB)
    XCTAssertTrue(
        actualPointB =~= expectedPointA || actualPointB =~= expectedPointB)
  }


  // Verify that pointsAtDistance:onLine:fromPoint works for vertical lines.
  func testPointsAtDistanceOnLineFromPoint_verticalLine() {
    let line = Line(point: CGPointZero, otherPoint: CGPoint(x: 0, y: 1))
    let point = CGPoint(x: 0, y: 5)
    let expectedPointA = CGPoint(x: 0, y: 6.5)
    let expectedPointB = CGPoint(x: 0, y: 3.5)

    let (actualPointA, actualPointB) = Line.pointsAtDistance(
        1.5, onLine: line, fromPoint: point)
    XCTAssertTrue(
        actualPointA =~= expectedPointA || actualPointA =~= expectedPointB)
    XCTAssertTrue(
        actualPointB =~= expectedPointA || actualPointB =~= expectedPointB)
  }


  // Verify that pointsAtDistance:onLine:fromPoint works for horizontal lines.
  func testPointsAtDistanceOnLineFromPoint_horizontalLine() {
    let line = Line(point: CGPointZero, otherPoint: CGPoint(x: 1, y: 0))
    let point = CGPoint(x: 5, y: 0)
    let expectedPointA = CGPoint(x: 10, y: 0)
    let expectedPointB = CGPoint(x: 0, y: 0)

    let (actualPointA, actualPointB) = Line.pointsAtDistance(
        5, onLine: line, fromPoint: point)
    XCTAssertTrue(
        actualPointA =~= expectedPointA || actualPointA =~= expectedPointB)
    XCTAssertTrue(
        actualPointB =~= expectedPointA || actualPointB =~= expectedPointB)
  }
}
