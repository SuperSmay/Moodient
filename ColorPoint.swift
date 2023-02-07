//
//  ColorPoint.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation
import SwiftUI

/// Just a baic struct to hold a color that can be converted to a SwiftUI color
struct ColorPoint: Codable {
    let hue: Double
    let saturation: Double
    let brightness: Double
    
    var swiftuiColor: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
}
