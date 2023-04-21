//
//  MoodientApp.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI

@main
struct MoodientApp: App {
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
