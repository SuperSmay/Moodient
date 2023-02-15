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
/// Not meant to be stored in the database, only created when loading from the database
struct MoodCalendarDay: Identifiable {
    
    var utcDate: Date
    var moodDay: MoodDay?
    var id: Int
    
}


