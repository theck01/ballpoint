//
//  CircularBrush.swift
//  ballpoint
//
//  Created by Tyler Heck on 8/2/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



/// A brush that paints by drawing a path at the desired location.
struct FountainBrush: Brush {
  /// The number of points within the transition from minimum radius to maximum
  /// radius.
  private let transitionPointCount: Int

  /// The mimimum radius of the brush path.
  private let minRadius: CGFloat

  /// The maximum radius of the brush path.
  private let maxRadius: CGFloat

  
  /**
   - parameter maxRadius: The maximum radius of the brush.
   */
  init(
      minRadius: CGFloat, maxRadius: CGFloat,
      transitionPointsFromMinToMaxSize: Int? = nil) {
    assert(
        minRadius <= maxRadius,
        "Cannot create a fountain brush with a minimum radius that is larger " +
        "than its maximum radius.")
    self.minRadius = minRadius
    self.maxRadius = maxRadius
    if let transitionPoints = transitionPointsFromMinToMaxSize {
      transitionPointCount = transitionPoints
    } else {
      transitionPointCount = Int(ceil((self.maxRadius - self.minRadius) * 2))
    }
  }
  
  
  /// MARK: Brush method implementations.

  func render(stroke: Stroke) -> RendererStroke? {
    if stroke.points.isEmpty {
      return nil
    }

    var paths: [CGPath] = []

    paths.append(pathAroundLocation(
        stroke.points.first!.location, radius: minRadius))

    if stroke.points.count > 1 {
      var previousRadius = minRadius
      for i in 1..<stroke.points.count {
        let radius = radiusForLocationNumber(i, of: stroke.points.count)

        paths.append(connectorPath(
            from: (
                location: stroke.points[i - 1].location,
                radius: previousRadius
            ),
            to: (
                location: stroke.points[i].location,
                radius: radius
            )))
        paths.append(
            pathAroundLocation(stroke.points[i].location, radius: radius))

        previousRadius = radius
      }
    }

    return RendererStroke(paths: paths, color: stroke.color)
  }

  
  /// MARK: Helper methods.
  
  /**
   - parameter location:

   - returns: The circular path centered at the given location.
   */
  private func pathAroundLocation(location: CGPoint, radius: CGFloat) -> CGPath {
    let path = CGPathCreateMutable()

    CGPathMoveToPoint(path, nil, location.x + radius, 0)
    CGPathAddArc(
        path, nil, location.x, location.y, radius, 0, CGFloat(M_PI), true)
    CGPathAddArc(
        path, nil, location.x, location.y, radius, CGFloat(M_PI),
        CGFloat(2 * M_PI), true)
    CGPathCloseSubpath(path)

    return path
  }
  
  
  /**
   - parameter a:
   - parameter b: Method assumes that b != a.

   - returns: The rectangular path from point A to B. One pair of sides runs
       parallel to the line between the two points (with equivalent length to
       the line between the points). The other pair of sides runs perpendicular
       to the line between the two points, with length equal to twice the radius
       and centered on each of the points.
   */
  private func connectorPath(
      from a: (location: CGPoint, radius: CGFloat),
      to b: (location: CGPoint, radius: CGFloat)) -> CGPath {
    let path = CGPathCreateMutable()
    
    // Special case when a.y == b.y, because then the perpendicular slope will
    // be infinite.
    if (a.location.y == b.location.y) {
      CGPathMoveToPoint(path, nil, a.location.x, a.location.y - a.radius)
      CGPathAddLineToPoint(path, nil, b.location.x, b.location.y - b.radius)
      CGPathAddLineToPoint(path, nil, b.location.x, b.location.y + b.radius)
      CGPathAddLineToPoint(path, nil, a.location.x, a.location.y + a.radius)
      CGPathCloseSubpath(path)
      return path
    }
    
    // Special case when a.x == b.x, because then the perpendicular slope will
    // be 0.
    if (a.location.x == b.location.x) {
      CGPathMoveToPoint(path, nil, a.location.x - a.radius, a.location.y)
      CGPathAddLineToPoint(path, nil, b.location.x - b.radius, b.location.y)
      CGPathAddLineToPoint(path, nil, b.location.x + b.radius, b.location.y)
      CGPathAddLineToPoint(path, nil, a.location.x + a.radius, a.location.y)
      CGPathCloseSubpath(path)
      return path
    }
    
    let perpendicularSlope =
        -((a.location.x - b.location.x) / (a.location.y - b.location.y))
    let perpendicularAIntercept =
        a.location.y - perpendicularSlope * a.location.x
    let perpendicularBIntercept =
        b.location.y - perpendicularSlope * b.location.x
    
    // The change in x required to move the size of the radius from a point
    // along the slope perpendicular to the line between a and b.
    let deltaXForA = sqrt(
        (a.radius * a.radius) / (1 + perpendicularSlope * perpendicularSlope))
    let deltaXForB = sqrt(
        (b.radius * b.radius) / (1 + perpendicularSlope * perpendicularSlope))
    
    var x = a.location.x + deltaXForA
    var y = perpendicularSlope * x + perpendicularAIntercept
    CGPathMoveToPoint(path, nil, x, y)
    
    x = b.location.x + deltaXForB
    y = perpendicularSlope * x + perpendicularBIntercept
    CGPathAddLineToPoint(path, nil, x, y)
    
    x = b.location.x - deltaXForB
    y = perpendicularSlope * x + perpendicularBIntercept
    CGPathAddLineToPoint(path, nil, x, y)
    
    x = a.location.x - deltaXForA
    y = perpendicularSlope * x + perpendicularAIntercept
    CGPathAddLineToPoint(path, nil, x, y)
    CGPathCloseSubpath(path)
    
    return path
  }


  private func radiusForLocationNumber(n: Int, of total: Int) -> CGFloat {
    let radiusDiff = maxRadius - minRadius
    let candidateRadiusFromBeginning =
        minRadius + radiusDiff * (CGFloat(n) / CGFloat(transitionPointCount))
    let candidateRadiusFromEnd =
        minRadius +
        radiusDiff * (CGFloat(total - n - 1) / CGFloat(transitionPointCount))

    return fmin(
        fmin(candidateRadiusFromBeginning, candidateRadiusFromEnd), maxRadius)
  }
}