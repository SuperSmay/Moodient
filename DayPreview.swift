//
//  DayPreview.swift
//  Moodient
//
//  Created by Smay on 2/4/23.
//

import SwiftUI
import NaiveDate

/// Used for a quick preview of the day. Not meant to be interactive
struct DayPreview: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var date: Date
    @State var dateOpenedTo: Date?
    @State var moodValue: Int
    @State var description: String
    
    /// Initialize the view with a date, a mood value, and a description
    init(naiveDate: NaiveDate?, moodValue: Int, description: String) {
        
        var initialDate = Date.now
        if naiveDate != nil {
            initialDate = Calendar.current.date(from: naiveDate!) ?? Date.now
        }
        
        self._date = State(initialValue: initialDate)
        if naiveDate != nil {
            self._dateOpenedTo = State(initialValue: initialDate)
        }
        self._moodValue = State(initialValue: moodValue)
        self._description = State(initialValue: description)
    }
    
    var body: some View {
        /// Pretty simple, we got a ZStack with a form and a linear gradient background
        NavigationView {
            
            ZStack {
                
                LinearGradient(colors: [.gray.opacity(0.1), MoodOptions().colors[moodValue].swiftuiColor.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                Form {
                    /// Used for display only
                    Picker("Mood", selection: $moodValue) {
                        ForEach(0..<5) { value in
                            Text(MoodOptions().labels[value])
                        }
                    }
                    
                    TextField("Description", text: $description, axis: .vertical)
                    
                }
                /// Disables the gray/black default background
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        }
        .onAppear() {
            
            
            
        }
    }
}


struct DayPreview_Previews: PreviewProvider {
    static var previews: some View {
        DayPreview(naiveDate: NaiveDate(year: 2022, month: 1, day: 1), moodValue: 0, description: "")
    }
}
