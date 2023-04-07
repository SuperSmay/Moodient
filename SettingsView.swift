//
//  SettingsView.swift
//  Moodient
//
//  Created by Smay on 2/5/23.
//

import SwiftUI

struct SettingsView: View {
    
    /// The actual state variables to use for the UI, initialized to the values of the stored settings
    @State private var labels = MoodOptions.options.moodLabels
    @State private var colors = MoodOptions.options.moodColors
    
    var body: some View {
        
        /// The custom bindings to use to update the settings and the UI with whatever the new values are
        /// Simply having these bindings return the stored value in the Options clas was not working, the values were being overwritten, hence the @State vars above
        let moodLabels = Binding<[String]> {
            labels
        } set: { newValue in
            labels = newValue
            MoodOptions.options.moodLabels = newValue
        }
        
        let moodColors = Binding<[Color]> {
            colors
        } set: { newValue in
            colors = newValue
            MoodOptions.options.moodColors = newValue
        }
        
        NavigationView {
            Form {
                Section("Moods and colors") {
                    
                    ForEach(0..<5) { index in
                        HStack {
                            TextField("Test", text: moodLabels[index])
                                .submitLabel(.done)
                            ColorPicker("Color", selection: moodColors[index], supportsOpacity: false)
                                .labelsHidden()
                                
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Text("About")
                    }

                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
