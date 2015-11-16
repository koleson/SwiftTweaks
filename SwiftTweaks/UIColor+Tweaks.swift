//
//  UIColor+Tweaks.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

// info via http://arstechnica.com/apple/2009/02/iphone-development-accessing-uicolor-components/
internal extension UIColor {
	internal convenience init?(hexString: String) {
		// Strip whitespace, "#", "0x", and make uppercase
		let hexString = hexString
			.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "#"))
			.stringByReplacingOccurrencesOfString("0x", withString: "")
			.uppercaseString

		// We should have 6 or 8 characters now.
		let hexStringLength = hexString.characters.count
		if (hexStringLength != 6) && (hexStringLength != 8) {
			return nil
		}

		// Break the string into its components
		let hexStringContainsAlpha = (hexStringLength == 8)
		let colorStrings: [String] = [
			hexString[hexString.startIndex...hexString.startIndex.advancedBy(1)],
			hexString[hexString.startIndex.advancedBy(2)...hexString.startIndex.advancedBy(3)],
			hexString[hexString.startIndex.advancedBy(4)...hexString.startIndex.advancedBy(5)],
			hexStringContainsAlpha ? hexString[hexString.startIndex.advancedBy(6)...hexString.startIndex.advancedBy(7)] : "FF"
		]

		// Convert string components into their CGFloat (r,g,b,a) components
		let colorFloats: [CGFloat] = colorStrings.map {
			var componentInt: CUnsignedInt = 0
			NSScanner(string: $0).scanHexInt(&componentInt)
			return CGFloat(componentInt) / CGFloat(255.0)
		}

		self.init(red: colorFloats[0], green: colorFloats[1], blue: colorFloats[2], alpha: colorFloats[3])
	}

	internal convenience init(hex: UInt32, alpha: CGFloat = 1) {
		self.init(
			red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat((hex & 0x0000FF)) / 255.0,
			alpha: alpha
		)
	}

	internal var hexString: String {
		assert(canProvideRGBComponents, "Must be an RGB color to use UIColor.hexValue")

		let components = CGColorGetComponents(self.CGColor)

		return String(format: "#%02x%02x%02x%02x", arguments: [
			Int(components[0] * 255.0),
			Int(components[1] * 255.0),
			Int(components[2] * 255.0),
			Int(components[3] * 255.0)
			]).uppercaseString
	}

	private var canProvideRGBComponents: Bool {
		switch CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor)) {
		case .RGB, .Monochrome:
			return true
		default:
			return false
		}
	}
}