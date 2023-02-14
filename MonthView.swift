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
    
    private var days = [Date]()
    private var weeks = [[Date]]()
    private var daysToSkipInFirstWeek = 0
    
    var firstDayOfMonth: Date
    
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
                        
                        
                            
//                            let delayWeek = week.firstIndex(of: day) ?? 0
//                            let delayMonth = weeks.firstIndex(of: week) ?? 0
//                            let totalMonthDelay = delayMonth * week.count
                            
                            MonthDayView(date: day)
//                                .offset(y: isTransitioning ? mainWindowSize.height + geo.size.height * 3 - geo.frame(in: .global).origin.y : 0)
//                                .animation(.easeOut(duration: 0.25).delay(Double(totalMonthDelay + delayWeek)/100), value: isTransitioning)
                        
                        
                            
                        
                    }
                }
            }
        }
    }

    
    init(dayInMonth givenDate: Date) {
        
        /// Set the first day of the month
        let components = Calendar.current.dateComponents([.year, .month], from: givenDate)
        firstDayOfMonth = Calendar.current.date(from: DateComponents(year: components.year ?? 1, month: components.month, day: 1)) ?? Date.now
        
        /// Save the month
        let month = components.month
        
        if month == nil {
            print("Unable to get month from given Date: \(givenDate)")
            return
        }
        
        /// Start with the first day of the month, then loop untill the month is no longer the same, filling days with the days in that month
        var currentDay: Date? = firstDayOfMonth
        while (currentDay != nil && Calendar.current.dateComponents([.month], from: currentDay!).month == month) {
            days.append(currentDay!)
            currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay!)
        }
        
        /// Fill the week with days, then reset at the start of each new week
        var currentWeek = [Date]()
        
        daysToSkipInFirstWeek = (Calendar.current.dateComponents([.weekday], from: firstDayOfMonth).weekday ?? 0) - 1
        
        for day in days {
            /// The index of a day in the current calender's week (Starts at 1, eg Sunday = 1)
            let weekIndex = Calendar.current.dateComponents([.weekday], from: day).weekday
            
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
        MonthView(dayInMonth: Date.now)
    }
}
