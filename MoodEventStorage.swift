//
//  MoodDayList.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation
import SQLite
import NaiveDate

class MoodEventStorage {
    
    // MARK: - Database contants
    
    static let DIR_MOOD_EVENTS_DB = "MoodEventsDB"
    static let DB_NAME = "moods.sqlite3"
    
    private let moodDaysTable = Table("moodEvents")
    
    private let id = Expression<Int>("id")
    private let naiveDate = Expression<NaiveDate>("naiveDate")
    private let moodDay = Expression<MoodDay>("moodEvent")
    
    /// Singleton moment
    static let moodEventStore = MoodEventStorage()
    
    /// The actual connection
    private var db: Connection? = nil
    
    
    /// Init to connect to the database and create the singleton
    private init() {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = documentsDir.appendingPathComponent(Self.DIR_MOOD_EVENTS_DB)
            
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let dbPath = dirPath.appendingPathComponent(Self.DB_NAME).path
                db = try Connection(dbPath)
                createTable()
                print("Database created successfully at: \(dbPath)")
            } catch {
                /// Most of time this will be the error about the table already existing
                print("Database init error: \(error)")
            }
        } else {
            print("Documents directory unknown")
        }
    }
    
    /// Create the table
    private func createTable() {
        guard let database = db else {
            print("Database is nil, unable to create table")
            return
        }
        do {
            /// Setup columns
            try database.run(moodDaysTable.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(naiveDate)
                table.column(moodDay)
            })
            print("Table created")
        } catch {
            print("Table create error: \(error)")
        }
    }
    
    /// Yeet the table (this is for testing and that's pretty much it)
    func deleteTable() {
        guard let database = db else {
            print("Database is nil, unable to create table")
            return
        }
        do {
            try database.run(moodDaysTable.drop())
            print("Table dropped")
        } catch {
            print("Table drop error: \(error)")
        }
    }
    
    // MARK: - Database operations
    /// Pretty straight forward in how these work, got them from
    /// https://blog.canopas.com/ios-persist-data-using-sqlite-swift-library-with-swiftui-example-c5baefc04334
    func insert(naiveDate: NaiveDate, moodDay: MoodDay) -> Int? {
        guard let database = db else { return nil }

        let insert = moodDaysTable.insert(self.naiveDate <- naiveDate, self.moodDay <- moodDay)
    
        do {
            let rowID = try database.run(insert)
            return Int(rowID)
        } catch {
            print(error)
            return nil
        }
    }

    func getAllMoodDays() -> [MoodCalendarDay] {
        var moodDays = [MoodCalendarDay]()
        guard let database = db else { return [] }

        do {
            for entry in try database.prepare(self.moodDaysTable) {
                do {
                    let newDay = MoodCalendarDay(naiveDate: try entry.get(naiveDate), moodDay: try entry.get(moodDay), id: try entry.get(id))
                    moodDays.append(newDay)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        return moodDays
    }


    func findMoodDay(eventId: Int) -> MoodCalendarDay? {
        var foundMoodDay: MoodCalendarDay? = nil
        guard let database = db else { return nil }

        let filter = self.moodDaysTable.filter(id == eventId)
        do {
            for m in try database.prepare(filter) {
                foundMoodDay = MoodCalendarDay(naiveDate: m[naiveDate], moodDay: m[moodDay], id: m[id])
            }
        } catch {
            print(error)
        }
        return foundMoodDay
    }
    
    func findMoodDay(searchNaiveDate: NaiveDate?) -> MoodCalendarDay? {
        
        if searchNaiveDate == nil {
            return nil
        }
        
        var foundMoodDay: MoodCalendarDay? = nil
        guard let database = db else { return nil }

        let filter = self.moodDaysTable.filter(naiveDate == searchNaiveDate!)
        do {
            for m in try database.prepare(filter) {
                foundMoodDay = MoodCalendarDay(naiveDate: m[naiveDate], moodDay: m[moodDay], id: m[id])
            }
        } catch {
            print(error)
        }
        return foundMoodDay
    }

    func update(id: Int, naiveDate: NaiveDate, moodDay: MoodDay) -> Bool {
        guard let database = db else { return false }

        let moodEvent = moodDaysTable.filter(self.id == id)
        do {
            let update = moodEvent.update([
                self.naiveDate <- naiveDate,
                self.moodDay <- moodDay
            ])
            if try database.run(update) > 0 {
                return true
            }
        } catch {
            print(error)
        }
        return false
    }

    func delete(id: Int) -> Bool {
        guard let database = db else {
            return false
        }
        do {
            let filter = moodDaysTable.filter(self.id == id)
            try database.run(filter.delete())
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func delete(naiveDate: NaiveDate?) -> Bool {
        
        if naiveDate == nil {
            return false
        }
        
        guard let database = db else {
            return false
        }
        do {
            let filter = moodDaysTable.filter(self.naiveDate == naiveDate!)
            try database.run(filter.delete())
            return true
        } catch {
            print(error)
            return false
        }
    }
    
}

