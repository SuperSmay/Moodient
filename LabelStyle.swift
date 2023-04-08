//
//  LabelStyle.swift
//  Moodient
//
//  Created by Smay on 4/8/23.
//

import SwiftUI

/// https://stackoverflow.com/a/69837612
struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .font(.system(size: 17))
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 7).frame(width: 28, height: 28).foregroundColor(color))
        }
    }
}
