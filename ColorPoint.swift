//
//  ColorPoint.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation
import SwiftUI

struct ColorPoint: Codable {
    let hue: Double
    let saturation: Double
    let brightness: Double
    
    var swiftuiColor: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
}
