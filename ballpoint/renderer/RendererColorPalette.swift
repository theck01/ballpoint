//
//  RenderColor.swift
//  ballpoint
//
//  Created by Tyler Heck on 9/8/15.
//  Copyright (c) 2015 Tyler Heck. All rights reserved.
//

import UIKit



typealias RendererColorId = String



/// A renderer color, which is an wrapper around a variable UIColor with
/// constant ID, allowing color schemes to be swapped without updates all color
/// holding objects.
protocol RendererColor {
  var id: RendererColorId { get }
  var backingColor: UIColor { get }
  var red: CGFloat { get }
  var green: CGFloat { get }
  var blue: CGFloat { get }
  var alpha: CGFloat { get }
}



/// A listener for changes to the color palette.
protocol RendererColorPaletteUpdateListener {
  /**
   Called when the render color is updated to a new value.

   :param: color The color that updated its value.
   */
  func didUpdateRenderColorPalette(palette: RendererColorPalette)
}



/// A collection of render color's that make up a unique unit.
class RendererColorPalette {
  /// The backing instance for the default palette.
  private static var defaultPaletteInstance: RendererColorPalette?

  /// The default shared palette used by most classes within an application.
  static var defaultPalette: RendererColorPalette {
    if defaultPaletteInstance == nil {
      defaultPaletteInstance = RendererColorPalette()
    }
    return defaultPaletteInstance!
  }

  private var colors: [RendererColorId: RendererColorImpl] = [:]

  /// The listeners interested in changes to this palette.
  private var listeners: [RendererColorPaletteUpdateListener] = []


  /**
   :param: id The id of the renderer color to retrieve. Presence of the ID
       within the palette is asserted.

   :return: The renderer color with the given ID.
   */
  subscript(id: RendererColorId) -> RendererColor {
    assert(colors[id] != nil, "Cannot retrieve a non-existant RendererColor.")
    return colors[id]!
  }


  /**
   Registers new color with initial backing colors within palette.

   :param: colors A map between renderer color IDs to update and initial
       backing colors.
   */
  func registerPalette(colors: [RendererColorId: UIColor]) {
    for id in colors.keys {
      assert(
          self.colors[id] == nil,
          "Cannot register a RendererColorId multiple times.")
      self.colors[id] = RendererColorImpl(id: id, backingColor: colors[id]!)
    }
  }


  /**
   Registers the given listener for future palette updates.

   :param: listener
   */
  func registerColorPaletteUpdateListener(
      l: RendererColorPaletteUpdateListener) {
    listeners.append(l)
  }


  /**
   Updates the backing colors of each RendererColor associated with the given
   IDs.

   :param: colorChanges A map between renderer color IDs to update and new
       backing colors.
   */
  func updatePalette(colorChanges: [RendererColorId: UIColor]) {
    for id in colorChanges.keys {
      assert(
          colors[id] != nil,
          "Cannot update the backing color of a non-existant RendererColor.")
      colors[id]?.backingColor = colorChanges[id]!
    }

    updateListeners()
  }


  /// Updates the listeners that a color change occured.
  private func updateListeners() {
    for l in listeners {
      l.didUpdateRenderColorPalette(self)
    }
  }

}



/// A private implementation of the RendererColor protocol that prevents
/// external sources from creating RenderColors outside of a palette.
private class RendererColorImpl: RendererColor {
  let id: RendererColorId

  var backingColor: UIColor {
    didSet {
      updateColorComponentsWithColor(backingColor)
    }
  }

  var red: CGFloat
  var green: CGFloat
  var blue: CGFloat
  var alpha: CGFloat


  init(id: RendererColorId, backingColor: UIColor) {
    self.id = id
    self.backingColor = backingColor
    red = 0
    green = 0
    blue = 0
    alpha = 0

    updateColorComponentsWithColor(backingColor)
  }


  func updateColorComponentsWithColor(color: UIColor) {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    backingColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    red = r
    blue = b
    green = g
    alpha = a
  }
}
