//
//  NaiveDateExtensions.swift
//  Moodient
//
//  Created by Smay on 2/7/23.
//

import Foundation
import SQLite

// MARK: - Date extension for converting Date to midnight UTC on that day
extension Date {
    var convertedUtcDate: Date? {
        /// Not really sure what to do if this ever fails, hopefully that doesn't happen

        /// Lets find out what happens
        /// edit: Seems to work as expected
        // return nil
        
        let secondsOffset = TimeZone.autoupdatingCurrent.secondsFromGMT()
        
        var currentTimezoneCalendar = Calendar.autoupdatingCurrent
        currentTimezoneCalendar.timeZone = TimeZone(secondsFromGMT: secondsOffset)!
        
        var realDate = currentTimezoneCalendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)
        
        if realDate == nil {
            return nil
        }
        
        realDate = currentTimezoneCalendar.date(byAdding: .second, value: secondsOffset, to: realDate!)
        
        return realDate
    }
    
    var convertedUtcTime: Date? {
        let secondsOffset = TimeZone.autoupdatingCurrent.secondsFromGMT()
        let utcTime = Calendar.autoupdatingCurrent.date(byAdding: .second, value: secondsOffset, to: self)        
        return utcTime
    }
    
    var convertedCurrentTimezoneDate: Date? {
        /// Not really sure what to do if this ever fails, hopefully that doesn't happen

        /// Lets find out what happens
        /// edit: Seems to work as expected
        // return nil
        
        let secondsOffset = TimeZone.autoupdatingCurrent.secondsFromGMT()
        
        //var realDate = Calendar.autoupdatingCurrent.date(bySettingHour: 0, minute: 0, second: 0, of: self)
        
        //if realDate == nil {
         //   return nil
        //}
        
        let realDate = Calendar.autoupdatingCurrent.date(byAdding: .second, value: -1 * secondsOffset, to: self)
        
        return realDate
    }
}

// MARK: - Painful date extension for checking if the user is in 24 hour mode
/// https://stackoverflow.com/a/33468088 
extension Date {

    static var is24HoursFormat : Bool  {
        let dateString = Date.localFormatter.string(from: Date())

        if dateString.contains(Date.localFormatter.amSymbol) || dateString.contains(Date.localFormatter.pmSymbol) {
            return false
        }

        return true
    }

    private static let localFormatter : DateFormatter = {
        let formatter = DateFormatter()

        formatter.locale    = Locale.autoupdatingCurrent
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        return formatter
    }()
}

extension Date: Identifiable {
    public var id: TimeInterval {
        return self.timeIntervalSince1970
    }
}
