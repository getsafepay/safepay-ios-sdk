//
//  Colors.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct Colors {
    static let blue = UIColor(hex: "#19398C")
    static let lightBlue = UIColor(hex: "#eef4f7")
    static let disable =  UIColor(hex: "#DFDFDF")
    static let error = UIColor.red
    static let fieldBorder = UIColor(hex: "#BEBEBE")
    static let activeFieldBorder = UIColor(hex: "#19398C")
    static let fieldTextColor = UIColor.black
    static let fieldBackgroundColor = UIColor.white
    static let fieldPlaceholderColor = UIColor(hex: "#686868")
    static let viewBGColor = UIColor.white

}
