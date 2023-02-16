//
//  MonthView.swift
//  Moodient
//
//  Created by Smay on 2/8/23.
//

import SwiftUI
import NaiveDate

struct MonthView: View {
    
    /// The size of the window this view is being displayed in
    @Environment(\.mainWindowSize) var mainWindowSize

    private var weeks: [[Date]]
    private var daysToSkipInFirstWeek = 0
    
    var firstDayOfMonth: Date
    
    @State private var moodDays: [MoodCalendarDay]
    
    var body: some View {
        Grid {
            ForEach(weeks, id: \.self) { week in
                GridRow {
                    
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
                        let moodCalendarDay = moodDays.first(where: { $0.utcDate == day.convertedUtcDate}) ?? MoodCalendarDay(utcDate: day.convertedUtcDate ?? Date.now, id: -1)
                        
                        MonthDayView(moodCalendarDay: moodCalendarDay)
                            /// Allow subviews to access this callback
                            .environment(\.reload, reload)
                    
                    }
                }
            }
        }
    }

    /// Reloads all data from the database
    func reload() {
        moodDays = MoodEventStorage.moodEventStore.getAllMoodDays()
    }
    
    init(dayInMonth givenDate: Date) {
        
        weeks = [[Date]]()
        let initialMoodDays = MoodEventStorage.moodEventStore.getAllMoodDays()
        _moodDays = State(initialValue: initialMoodDays)
        
        /// Set the first day of the month
        let components = Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: givenDate)
        firstDayOfMonth = Calendar.autoupdatingCurrent.date(from: DateComponents(year: components.year ?? 1, month: components.month, day: 1)) ?? Date.now
        
        /// Save the month
        let month = components.month
        
        if month == nil {
            print("Unable to get month from given Date: \(givenDate)")
            return
        }
        
        /// Start with the first day of the month, then loop untill the month is no longer the same, filling days with the days in that month
        var days = [Date]()
        var currentDay: Date? = firstDayOfMonth
        while (currentDay != nil && Calendar.autoupdatingCurrent.dateComponents([.month], from: currentDay!).month == month) {
            days.append(currentDay!)
            currentDay = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: currentDay!)
        }
        
        /// Fill the week with days, then reset at the start of each new week
        var currentWeek = [Date]()
        
        daysToSkipInFirstWeek = (Calendar.autoupdatingCurrent.dateComponents([.weekday], from: firstDayOfMonth).weekday ?? 0) - 1
        
        for day in days {
            /// The index of a day in the current calender's week (Starts at 1, eg Sunday = 1)
            let weekIndex = Calendar.autoupdatingCurrent.dateComponents([.weekday], from: day).weekday
            
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

private struct ReloadKey: EnvironmentKey {
    static let defaultValue: () -> () = {}
}

extension EnvironmentValues {
    var reload: () -> () {
        get { self[ReloadKey.self] }
        set { self[ReloadKey.self] = newValue }
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(dayInMonth: Date.now)
    }
}
