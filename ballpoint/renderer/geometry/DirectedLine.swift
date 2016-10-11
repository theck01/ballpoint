//
//  DirectedLine.swift
//  ballpoint
//
//  Created by Tyler Heck on 1/16/16.
//  Copyright © 2016 Tyler Heck. All rights reserved.
//

import CoreGraphics



/// A structure representation of a line and a direction.
public struct DirectedLine {
  /// The underlying line.
  let line: Line

  /// The direciton of the line.
  let direction: CGVector


  /**
   - parameter earlyPoint:
   - parameter latePoint:

   - returns The line between the two points, with direction provided from early
       to late, or nil if the points are identical.
   */
  public init?(earlyPoint: CGPoint, latePoint: CGPoint) {
    guard let line = Line(point: earlyPoint, otherPoint: latePoint)
        else { return nil }
    self.init(line: line, direction: CGVector(
        dx: latePoint.x - earlyPoint.x, dy: latePoint.y - earlyPoint.y))
  }


  /**
   - parameter line:
   - parameter direction:

   - returns:
   */
  public init(line: Line, direction: CGVector) {
    self.line = line
    self.direction = direction.vectorWithMagnitude(1)
  }
}



/// Collection of static methods for operating on DirectedLine objects.
public extension DirectedLine {
  enum Orientation {
    case left, right, neither
  }


  /**
   - parameter point:
   - parameter toLine:

   - returns: The orientation of the point to the line, if the observer orients
       themself to view the line as if directed straight upwards.
   */
  public static func orientationOfPoint(
      _ point: CGPoint, toLine line: DirectedLine) -> Orientation {
    // The shift required to shift the line such that it traverses through the
    // origin.
    var centerLineShift: CGVector
    if let yIntercept = line.line.yIntercept {
      centerLineShift = CGVector(dx: 0, dy: -yIntercept)
    } else {
      centerLineShift = CGVector(dx: -line.line.xIntercept!, dy: 0)
    }

    let pointVector = CGVector(
        dx: point.x + centerLineShift.dx,
        dy: point.y + centerLineShift.dy)
    let rotatedPointVector =
          pointVector.vectorRotatedBy(-line.direction.angleInRadians)
        
    return rotatedPointVector.dy =~= 0 ?
        Orientation.neither :
        rotatedPointVector.dy > 0 ? Orientation.left : Orientation.right
  }
}
