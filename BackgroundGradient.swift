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
        
        /// Sort the incoming list by hour
        let sorted = moodPoints//.sorted(by: {
//            let components0 = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: $0.utcTime)
//            let components1 = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: $1.utcTime)
//            return components0.hour ?? 0 < components1.hour ?? 0
            
        //        })
        
        /// Then add colors in the order of sorted list
        for i in sorted {
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
