//
//  DirectedLineTestCase.swift
//  ballpoint
//
//  Created by Tyler Heck on 1/16/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//

import XCTest

import ballpoint



class DirectedLineTestCase: XCTestCase {
  func testOrientationOfPointToLine() {
    var line = DirectedLine(
        earlyPoint: CGPoint.zero, latePoint: CGPoint(x: -1, y: 10))!
    XCTAssertEqual(
        DirectedLine.orientationOfPoint(CGPoint(x: -10, y: 1), toLine: line),
        DirectedLine.Orientation.left)

    line = DirectedLine(
        earlyPoint: CGPoint(x: 0, y : 5), latePoint: CGPoint(x: 10, y: 5))!
    XCTAssertEqual(
        DirectedLine.orientationOfPoint(CGPoint(x: -10, y: 1), toLine: line),
        DirectedLine.Orientation.right)

    line = DirectedLine(
        earlyPoint: CGPoint(x: 0, y : 5), latePoint: CGPoint(x: -1, y: 5))!
    XCTAssertEqual(
        DirectedLine.orientationOfPoint(CGPoint(x: -10, y: 4), toLine: line),
        DirectedLine.Orientation.left)
  }
}
