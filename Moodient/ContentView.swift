//
//  ContentView.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = ""
    
    @ObservedObject private var moodDays = MoodEventStorage.moodEventStore
    
    var body: some View {
        
        GeometryReader { geo in
            
            TabView(selection: $selectedTab) {
                
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "clock")
                    }
                    .tag("Today")
                
                FullEventView()
                    .tabItem {
                        Label("Day List", systemImage: "calendar")
                    }
                    .tag("Day List")
                
                SearchTabView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag("Search")
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag("Settings")

            }
            .environment(\.mainWindowSize, geo.size)
            .environment(\.selectedTabTitle, selectedTab)
            //.environmentObject(moodDays)
        }
    }
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
