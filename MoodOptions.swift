//
//  MoodOptions.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation

struct MoodOptions: Codable {
    
    var labels = [
        "Very Happy",
        "Happy",
        "Meh",
        "Sad",
        "Very Sad"
    ]
    
    var colors = [
        ColorPoint(hue: 0.894, saturation: 0.91, brightness: 0.27),
        ColorPoint(hue: 0.877, saturation: 0.96, brightness: 0.5),
        ColorPoint(hue: 0.899, saturation: 0.28, brightness: 0.9),
        ColorPoint(hue: 0.075, saturation: 0.19, brightness: 0.92),
        ColorPoint(hue: 0.078, saturation: 0.17, brightness: 1)
    ]
}


