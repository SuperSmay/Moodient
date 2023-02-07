//
//  MoodDay.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation
import NaiveDate
import SQLite

// MARK: - MoodDay

struct MoodDay: Codable, Value {
    
    // MARK: - SQLite Value protocol
    public static var declaredDatatype: String {
        String.declaredDatatype
    }

    public static func fromDatatypeValue(_ stringValue: String) -> MoodDay? {
        
        if let decodedData = Data(base64Encoded: stringValue) {
            do {
                return try JSONDecoder().decode(self, from: decodedData)
            } catch {
                print("Error loading MoodDay from database: \(error)")
            }
        }
        return nil
    }

    public var datatypeValue: String {
        
        do {
            return try JSONEncoder().encode(self).base64EncodedString()
        } catch {
            return ""
        }
    }
    
    // MARK: - The actual data
    
    init(moodPoints: [MoodPoint] = [], description: String = "") {
        self.moodPoints = moodPoints
        self.description = description
    }
    
    var moodPoints: [MoodPoint]
    var description: String
    
}

// MARK: - MoodPoint

struct MoodPoint: Codable {
    
    var naiveTime: NaiveTime
    var moodValue: Int
    
}

// MARK: - MoodCalendarDay

struct MoodCalendarDay: Identifiable {
    
    var naiveDate: NaiveDate
    var moodDay: MoodDay?
    var id: Int
    
}


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
