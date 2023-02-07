//
//  DayPreview.swift
//  Moodient
//
//  Created by Smay on 2/4/23.
//

import SwiftUI
import NaiveDate

struct DayPreview: View {
    
    let id: Int
    
    @State var date: Date = Date.now
    @State var moodValue: Int = 0
    @State var description: String = ""
    
    var convertedNaiveDate: NaiveDate {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year ?? 0
        let month = components.month ?? 1
        let day = components.day ?? 1
        
        return NaiveDate(year: year, month: month, day: day)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                LinearGradient(colors: [.gray.opacity(0.1), MoodOptions().colors[moodValue].swiftuiColor.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                
                
                Form {
                    
                    Picker("Mood", selection: $moodValue) {
                        ForEach(0..<5) { value in
                            Text(MoodOptions().labels[value])
                        }
                    }
                    
                    TextField("Description", text: $description, axis: .vertical)
                }
                .scrollContentBackground(.hidden)
                
                    
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        }
        .onAppear() {
            
            let moodCalendarDay = MoodEventStorage.moodEventStore.findMoodDay(eventId: id)
            
            var initialDate = Date.now
            if moodCalendarDay != nil && moodCalendarDay?.naiveDate != nil {
                initialDate = Calendar.current.date(from: moodCalendarDay!.naiveDate)!
            }
            
            var initialValue = 0
            if moodCalendarDay != nil && moodCalendarDay?.moodDay?.moodPoints[0].moodValue != nil && !(moodCalendarDay?.moodDay?.moodPoints.isEmpty)! {
                initialValue = (moodCalendarDay?.moodDay!.moodPoints[0].moodValue)!
            }
            
            var initialDescription = ""
            if moodCalendarDay != nil && moodCalendarDay?.moodDay != nil {
                initialDescription = (moodCalendarDay?.moodDay!.description)!
            }
            
            date = initialDate
            moodValue = initialValue
            description = initialDescription
            
        }
    }
}


struct DayPreview_Previews: PreviewProvider {
    static var previews: some View {
        DayPreview(id: -1)
    }
}
