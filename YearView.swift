//
//  YearView.swift
//  Moodient
//
//  Created by Smay on 3/1/23.
//

import SwiftUI

struct YearView: View {
    /// The size of the window this view is being displayed in
    @Environment(\.mainWindowSize) var mainWindowSize
    /// Select tab env stuff to reload when the tab is changed
    @Environment(\.selectedTabTitle) var selectedTab
    
    @ObservedObject private var moodDays = MoodEventStorage.moodEventStore

    private var weeks = [[Date]]()
    private var daysToSkipInFirstWeek = 0
    
    var utcFirstDayOfYear: Date
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum:50)), count: 10)) {
                    ForEach(weeks, id: \.self) { week in
                        weekView(weeks: weeks, week: week, daysToSkipInFirstWeek: daysToSkipInFirstWeek)
                    }
                }
                .drawingGroup()
            }
        }
    }
    
    struct weekView: View {
        
        @ObservedObject private var moodDays = MoodEventStorage.moodEventStore
        
        
        let weeks: [[Date]]
        let week: [Date]
        let daysToSkipInFirstWeek: Int
        
        
        
        var body: some View {
            
            /// Add blank spots to the first part of the month
            if weeks.first == week {
                ForEach(0..<daysToSkipInFirstWeek, id: \.self) { _ in
                    /// Empty cell (https://sarunw.com/posts/swiftui-grid/)
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                }
            }
            
            ForEach(week, id: \.self) { day in
                
                /// Retrieve the actual info for this day from the list loaded earlier
                /// If this day does not have an entry, then a blank entry is used
                let moodCalendarDay = moodDays.moodDays[day.convertedUtcDate ?? Date.now] ?? MoodCalendarDay(utcDate: day.convertedUtcDate ?? Date.now, id: -1)
                
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
    
    init(utcDayInYear givenDate: Date) {
        
        /// Timezone
        let timezone = TimeZone(secondsFromGMT: 0) ?? .autoupdatingCurrent
        
        /// Get the month and year
        let components = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: givenDate)
        
        /// Set the first day of the month
        utcFirstDayOfYear = Calendar.autoupdatingCurrent.date(from: DateComponents(timeZone: timezone, year: components.year, month: components.month, day: 1)) ?? Date.now
        
        /// Save the year
        let year = components.year
        
        if year == nil {
            print("Unable to get year from given Date: \(givenDate)")
            return
        }
        
        /// Start with the first day of the month, then loop untill the year is no longer the same, filling days with the days in that year
        var days = [Date]()
        var currentDay: Date? = utcFirstDayOfYear
        var currentComponents = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: currentDay!)
        while (currentDay != nil && currentComponents.year == year) {
            days.append(currentDay!)
            currentDay = Calendar.autoupdatingCurrent.date(from: DateComponents(timeZone: timezone, year: components.year, month: components.month, day: (currentComponents.day ?? -1) + 1))
            if currentDay == nil {
                break
            }
            currentComponents = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: currentDay!)
        }
        
        /// Fill the week with days, then reset at the start of each new week
        var currentWeek = [Date]()
        
        daysToSkipInFirstWeek = (Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: utcFirstDayOfYear).weekday ?? 0) - 1
        
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

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(utcDayInYear: Date.now.convertedUtcDate!)
    }
}
