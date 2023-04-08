//
//  DeveloperOptionsView.swift
//  Moodient
//
//  Created by Smay on 4/7/23.
//

import SwiftUI

struct DeveloperOptionsView: View {
    
    @AppStorage("developerMode") private var developerMode = false
    
    var body: some View {
        
        Form {
                
                Toggle("Developer Mode", isOn: $developerMode)
                
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
