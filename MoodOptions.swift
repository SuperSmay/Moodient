//
//  MoodOptions.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation
import SwiftUI

class MoodOptions: Codable {
    
    static let DIR_MOOD_OPTIONS = "MoodOptions"
    static let FILE_NAME = "options.json"
    
    static let options = MoodOptions()
    
    var moodLabels: [String] {
        get {
            return labels
        }
        set(newValue) {
            print(newValue)
            labels = newValue
            save()
        }
    }
    
    var moodColors: [Color] {
        get {
            var swiftUiColors = [Color]()
            for color in colors {
                swiftUiColors.append(color.swiftuiColor)
            }
            return swiftUiColors
        }
        set(newValue) {
            colors.removeAll()
            for color in newValue {
                let ui = UIColor(color)
                var hue: CGFloat = 0.0
                var saturation: CGFloat = 0.0
                var brightness: CGFloat = 0.0
                var alpha: CGFloat = 0.0
                
                ui.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                
                colors.append(ColorPoint(hue: hue, saturation: saturation, brightness: brightness))
            }
            save()
        }
    }
    
    /// The labels used to display the moods
    private var labels = [
        "Very Happy",
        "Happy",
        "Meh",
        "Sad",
        "Very Sad"
    ]
    
    /// The colors used to represent the moods
    private var colors = [
        ColorPoint(hue: 0.894, saturation: 0.91, brightness: 0.27),
        ColorPoint(hue: 0.877, saturation: 0.96, brightness: 0.5),
        ColorPoint(hue: 0.899, saturation: 0.28, brightness: 0.9),
        ColorPoint(hue: 0.075, saturation: 0.19, brightness: 0.92),
        ColorPoint(hue: 0.078, saturation: 0.17, brightness: 1)
    ]
    
    private func save() {

        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = documentsDir.appendingPathComponent(Self.DIR_MOOD_OPTIONS)
            
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let jsonFilePath = dirPath.appendingPathComponent(Self.FILE_NAME)
                
                let encodedJSON = try JSONEncoder().encode(self)
                
                try encodedJSON.write(to: jsonFilePath)
                
                print("Options saved sucessfully at: \(jsonFilePath)")
            } catch {
                print("Options save error: \(error)")
            }
        } else {
            print("Documents directory unknown")
        }
    }
    
    private init() {
        
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = documentsDir.appendingPathComponent(Self.DIR_MOOD_OPTIONS)
            
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let jsonFilePath = dirPath.appendingPathComponent(Self.FILE_NAME)
                
                let data = try Data(contentsOf: jsonFilePath)
                
                let decodedJSON = try JSONDecoder().decode(MoodOptions.self, from: data)
                
                self.labels = decodedJSON.labels
                self.colors = decodedJSON.colors
                
                print("Options loaded sucessfully from: \(jsonFilePath)")
                
            } catch {
                print("Options load error: \(error)")
            }
        } else {
            print("Documents directory unknown")
        }
    }
    
    
}


