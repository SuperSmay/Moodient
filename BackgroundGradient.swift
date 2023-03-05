//
//  BackgroundGradient.swift
//  Moodient
//
//  Created by Smay on 2/27/23.
//

import SwiftUI

struct BackgroundGradient: View {
    
    let moodPoints: [MoodPoint]
    
    var colors: [Color] {
        var temp = [Color]()
        
        for i in moodPoints {
            temp.append(MoodOptions.options.moodColors[i.moodValue])
        }
        
        return temp
        
    }
    
    var body: some View {
        
        if colors.count == 0 {
            Color.secondary.opacity(0.25)
        } else {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        }
     
        
    }
    
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundGradient(moodPoints: [])
    }
}
