//
//  MonthView.swift
//  Moodient
//
//  Created by Smay on 2/8/23.
//

import SwiftUI

struct MonthView: View {
    
    /// The size of the window this view is being displayed in
    @Environment(\.mainWindowSize) var mainWindowSize
    /// Select tab env stuff to reload when the tab is changed
    @Environment(\.selectedTabTitle) var selectedTab
    
    @ObservedObject private var moodDays = MoodEventStorage.moodEventStore

    private var weeks = [[Date]]()
    private var daysToSkipInFirstWeek = 0
    
    var utcFirstDayOfMonth: Date
    
    var body: some View {
        VStack {

            Grid {
                
                GridRow {
                    
                    ForEach(Calendar.autoupdatingCurrent.shortWeekdaySymbols, id: \.self) { symbol in
                        
                        Text(symbol)
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .bold()
                            .foregroundColor(.secondary.opacity(0.75))
                    
                    }
                }
                
                ForEach(weeks, id: \.self) { week in
                    GridRow {
                        
                        /// Add blank spots to the first part of the month
                        if weeks.first == week {
                            WeekView(week: week, daysToSkipInWeek: daysToSkipInFirstWeek)
                        } else {
                            WeekView(week: week, daysToSkipInWeek: 0)
                        }
                    }
                }
            }
        }
        
    }
    
    struct WeekView: View {
        
        @ObservedObject private var moodDays = MoodEventStorage.moodEventStore
        
        let week: [Date]
        let daysToSkipInWeek: Int
    
        
        var body: some View {
            
            ForEach(0..<daysToSkipInWeek, id: \.self) { _ in
                /// Empty cell (https://sarunw.com/posts/swiftui-grid/)
                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])
            }
            
            
            
            ForEach(week, id: \.self) { day in
                
                /// Retrieve the actual info for this day from the list loaded earlier
                /// If this day does not have an entry, then a blank entry is used
                let moodCalendarDay = moodDays.moodDays[day] ?? MoodCalendarDay(utcDate: day , id: -1)
               
                
                MonthDayView(moodCalendarDay: moodCalendarDay)
                /// This *sucks.* The array change does not seem to be sufficient to trigger a reload of this view.
                /// This text background does reload as expected, and when it reloads it triggers the rest of the view to reload.
                /// This is probably a result of jank associated with how I'm fetching/storing this data.
                /// Anyway, if reloadCount is not updated for some reason, these days won't update :D
                    .background(Text(String(moodDays.reloadCount))
                        .foregroundColor(.clear))
                
                
            }
            
            
        }
    }
    
    init(utcDayInMonth givenUtcDate: Date) {
        
        /// Timezone
        let timezone = TimeZone(secondsFromGMT: 0) ?? .autoupdatingCurrent
        
        /// Get the month and year
        let components = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: givenUtcDate)
        
        /// Set the first day of the month
        utcFirstDayOfMonth = Calendar.autoupdatingCurrent.date(from: DateComponents(timeZone: timezone, year: components.year, month: components.month, day: 1)) ?? Date.now

        /// Save the month
        let month = components.month
        
        if month == nil {
            print("Unable to get month from given Date: \(givenUtcDate)")
            return
        }
        
        /// Start with the first day of the month, then loop untill the month is no longer the same, filling days with the days in that month
        var days = [Date]()
        var currentDay: Date? = utcFirstDayOfMonth
        var currentComponents = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: currentDay!)
        while (currentDay != nil && currentComponents.month == month) {
            days.append(currentDay!)
            currentDay = Calendar.autoupdatingCurrent.date(from: DateComponents(timeZone: timezone, year: components.year, month: components.month, day: (currentComponents.day ?? -1) + 1))
            if currentDay == nil {
                break
            }
            currentComponents = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: currentDay!)
        }
        
        /// Fill the week with days, then reset at the start of each new week
        var currentWeek = [Date]()
        
        daysToSkipInFirstWeek = (Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: utcFirstDayOfMonth).weekday ?? 0) - 1
        
        for day in days {
            /// The index of a day in the current calender's week (Starts at 1, eg Sunday = 1)
            let weekIndex = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: day).weekday
            
            /// If the day is not the first day of the week, just add it to the week
            if weekIndex != 1 {
                currentWeek.append(day)
                
            /// Otherwise, save the week, clear it, then add the first day to it
            } else {
                if currentWeek != [] {
                    weeks.append(currentWeek)
                }
                currentWeek = []
                currentWeek.append(day)
                
            }
        }
        
        /// Then, add the last week
        if currentWeek != [] {
            weeks.append(currentWeek)
        }
        
    }

}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(utcDayInMonth: Date.now.convertedUtcDate!)
    }
}
