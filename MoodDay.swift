//
//  MoodDay.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation
import SQLite

// MARK: - MoodDay

struct MoodDay: Codable, Value, Hashable {
    
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

/// A wrapper around a list of MoodPoints to store them in a database
struct MoodPointsList: Codable, Value, Hashable {
    
    // MARK: - SQLite Value protocol
    public static var declaredDatatype: String {
        String.declaredDatatype
    }

    public static func fromDatatypeValue(_ stringValue: String) -> MoodPointsList? {
        
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
    
    init(moodPoints: [MoodPoint] = []) {
        self.moodPoints = moodPoints
    }
    
    var moodPoints: [MoodPoint]
    
}

// MARK: - MoodPoint

struct MoodPoint: Codable, Hashable {
    
    var utcTime: Date
    var moodValue: Int
    
    let uuid = UUID()
    
    private enum CodingKeys: String, CodingKey {
            case utcTime, moodValue
        }
    
}

// MARK: - MoodCalendarDay
/// Not meant to be stored in the database, only created when loading from the database
struct MoodCalendarDay: Identifiable, Equatable, Hashable {
    
    static func == (lhs: MoodCalendarDay, rhs: MoodCalendarDay) -> Bool {
        lhs.utcDate == rhs.utcDate
    }
 
    var utcDate: Date
    var moodDay: MoodDay?
    var id: UUID
    
}
