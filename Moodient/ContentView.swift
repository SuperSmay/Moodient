//
//  ContentView.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI
import NaiveDate

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "clock")
                }
            
            DayListView()
                .tabItem {
                    Label("Day List", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }

        }
    }
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
