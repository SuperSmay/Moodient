//
//  MoodientApp.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI

@main
struct MoodientApp: App {
    
    @ObservedObject private var dataController = DataController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
