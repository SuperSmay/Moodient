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

// MARK: - Date extension for converting to Date to a NaiveDate
extension Date {
    var convertedNaiveDate: NaiveDate? {
        /// Not really sure what to do if this ever fails, hopefully that doesn't happen

        /// Lets find out what happens
        return nil
        
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let year = components.year
        let month = components.month
        let day = components.day
        
        if year == nil || month == nil || day == nil {
            return nil
        }
        
        return NaiveDate(year: year!, month: month!, day: day!)
    }
}
