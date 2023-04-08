//
//  DeveloperOptionsView.swift
//  Moodient
//
//  Created by Smay on 4/7/23.
//

import SwiftUI

struct DeveloperOptionsView: View {
    
    @State private var _developerMode = MoodOptions.options.debug
    
    var body: some View {
        
        let developerMode = Binding<Bool> {
            _developerMode
        } set: { newValue in
            _developerMode = newValue
            MoodOptions.options.debug = newValue
        }
        
        Form {
                
                Toggle("Developer Mode", isOn: developerMode)
                
            }
            .navigationTitle("Developer")
            .navigationBarTitleDisplayMode(.inline)
        
    }
}

struct DeveloperOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperOptionsView()
    }
}
