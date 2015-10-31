//
//  PointUtilTestCase.swift
//  ballpoint
//
//  Created by Tyler Heck on 10/31/15.
//  Copyright © 2015 Tyler Heck. All rights reserved.
//

import XCTest

import ballpoint



class PointUtilTestCase: XCTestCase {
  func testArePointsCollinear() {
    XCTAssertFalse(PointUtil.arePointsCollinear())
    XCTAssertFalse(PointUtil.arePointsCollinear(CGPointZero))
    XCTAssertTrue(PointUtil.arePointsCollinear(CGPointZero, CGPointZero))
    XCTAssertTrue(PointUtil.arePointsCollinear(
        CGPointZero, CGPoint(x: 1, y: 0)))
    XCTAssertTrue(PointUtil.arePointsCollinear(
        CGPointZero, CGPoint(x: 1, y: 1), CGPoint(x: -100, y: -100),
        CGPoint(x: 15.56, y: 15.56)))
    XCTAssertFalse(PointUtil.arePointsCollinear(
        CGPointZero, CGPoint(x: 1, y: 1), CGPoint(x: 100, y: -100),
        CGPoint(x: 15.56, y: 15.56)))
  }
}
