//
//  DeveloperOptionsView.swift
//  Moodient
//
//  Created by Smay on 4/7/23.
//

import SwiftUI
import CoreData

struct DeveloperOptionsView: View {
    
    @AppStorage("developerMode") private var developerMode = false
    @Environment(\.managedObjectContext) var moc
    
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
