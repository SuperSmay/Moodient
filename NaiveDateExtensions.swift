//
//  NaiveDateExtensions.swift
//  Moodient
//
//  Created by Smay on 2/7/23.
//

import Foundation
import SQLite
import NaiveDate

// MARK: - NaiveDate extension for SQLite compatability

extension NaiveDate: Value {
    
    /// Tell SQLite.swift to use strings to store/load NaiveDates
    public static var declaredDatatype: String {
        String.declaredDatatype
    }
    
    /// Load a NaiveDate from a stored string
    public static func fromDatatypeValue(_ stringValue: String) -> NaiveDate? {
        
        /// First, try decoding the base64 encoded string into data. If the data is nil, then something bad happened
        guard let decodedData = Data(base64Encoded: stringValue) else {
            print("Error decoding NaiveDate from database: \(stringValue) decoded to nil")
            return nil
        }
        
        /// Try to decode the data back into a NaiveDate
        do {
            return try JSONDecoder().decode(self, from: decodedData)
        } catch {
            print("Error loading NaiveDate from database: \(error)")
        }
        
        return nil
        
    }
        
        
    

    /// Convert a NaiveDate into base64EncodedString JSON
    public var datatypeValue: String {
        do {
            return try JSONEncoder().encode(self).base64EncodedString()
        } catch {
            print("Encoding \(self) to JSON failed")
            return ""
        }
    }
}

// MARK: - Date extension for converting Date to midnight UTC on that day
extension Date {
    var convertedUtcDate: Date? {
        /// Not really sure what to do if this ever fails, hopefully that doesn't happen

        /// Lets find out what happens
        /// edit: Seems to work as expected
        // return nil
        
        let secondsOffset = TimeZone.current.secondsFromGMT()
        
        var realDate = Calendar.autoupdatingCurrent.date(bySettingHour: 0, minute: 0, second: 0, of: self)
        
        if realDate == nil {
            return nil
        }
        
        realDate = Calendar.autoupdatingCurrent.date(byAdding: .second, value: secondsOffset, to: realDate!)
        
        return realDate
    }
    
    var convertedCurrentTimezoneDate: Date? {
        /// Not really sure what to do if this ever fails, hopefully that doesn't happen

        /// Lets find out what happens
        /// edit: Seems to work as expected
        // return nil
        
        let secondsOffset = TimeZone.current.secondsFromGMT()
        
        //var realDate = Calendar.autoupdatingCurrent.date(bySettingHour: 0, minute: 0, second: 0, of: self)
        
        //if realDate == nil {
         //   return nil
        //}
        
        let realDate = Calendar.autoupdatingCurrent.date(byAdding: .second, value: -1 * secondsOffset, to: self)
        
        return realDate
    }
}
