//
//  MoodDayList.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import Foundation
import SQLite
import CoreData

class MoodEventStorage: ObservableObject {
    
    // MARK: - Database contants
    
    static let DIR_MOOD_EVENTS_DB = "MoodEventsDB"
    static let DB_NAME = "moods.sqlite3"
    
    private let moodDaysTable = VirtualTable("moodEvents")
    
    private let utcDate = Expression<Date>("utcDate")
    private let moodPointsList = Expression<SQMoodPointsList>("moodPointsList")
    private let description = Expression<String>("description")
    private let uuid = Expression<UUID>("uuid")
    
    /// Singleton moment
    static let moodEventStore = MoodEventStorage()
    
    /// The actual connection
    private var db: Connection? = nil
    
    
    // MARK: - Live updated list of every mood day
    @Published var moodDays = [Date: SQMoodCalendarDay]()
    @Published var reloadCount = 0 /// Please help this is so jank
    /// reloadCount is needed because the ForEach grid that makes the calendar view does not want to reload from a change of the array
    /// Each day has an invisible reloadCount text view that gets updated, which triggers the rest of that view to reload.
    /// If reloadCount is not updated with the array above, the calendar view will not reload properly.
    
    
    /// Init to connect to the database and create the singleton
    private init() {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = documentsDir.appendingPathComponent(Self.DIR_MOOD_EVENTS_DB)
            
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let dbPath = dirPath.appendingPathComponent(Self.DB_NAME).path
                db = try Connection(dbPath)
                createTable()
                moodDays = getAllMoodDays()
                reloadCount += 1
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
        
        /// List to fill with days that need to be transferred if any do
        var moodDays = [Date: SQMoodCalendarDay]()
        
        if db?.userVersion == 1 {
            
            print("Database version \(String(describing: db?.userVersion))")
            
            saveBackup()
            
            let moodDaysTable = Table("moodEvents")
            
            let moodDay = Expression<SQMoodDay>("moodDay")
            
            /// The version check succeeded, so the database is not nil
            let database = db!
            
            do {
                for entry in try database.prepare(moodDaysTable) {
                    do {
                        let utcDate = try entry.get(utcDate)
                        let moodDay = try entry.get(moodDay)

                        moodDays[utcDate] = SQMoodCalendarDay(utcDate: utcDate, moodDay: moodDay, id: UUID())
                        
                    } catch {
                        print(error)
                    }
                }
                
                deleteTable()
                
            } catch {
                print(error)
            }
            
            
            
        }
        
        if db?.userVersion == 2 {
            
            let context = DataController.shared.container.viewContext
            
            print("Database version \(String(describing: db?.userVersion))")
            
            saveBackup()
            
            /// The version check succeeded, so the database is not nil
            let database = db!
            
            do {
                for entry in try database.prepare(self.moodDaysTable) {
                    do {
                        let newDay = SQMoodCalendarDay(utcDate: try entry.get(utcDate), moodDay: SQMoodDay(moodPoints: try entry.get(moodPointsList).moodPoints, description: try entry.get(description)), id: try entry.get(uuid))
                    
                        let newMoodDay = MoodDay(context: context)
                        newMoodDay.id = newDay.id
                        newMoodDay.dayDescription = newDay.moodDay?.description ?? ""
                        newMoodDay.utcDate = newDay.utcDate
                        
                        var newMoodPoints = [MoodPoint]()
                        
                        for sqMoodPoint in newDay.moodDay?.moodPoints ?? [] {
                            newMoodPoints.append(MoodPoint(utcTime: sqMoodPoint.utcTime, moodValue: sqMoodPoint.moodValue))
                        }
                        newMoodDay.moodPoints = newMoodPoints
                        
                        try context.save()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error)
            }
            
            
        }
        
        do {
            
            db?.userVersion = 3
            
            print("Database version \(String(describing: db?.userVersion))")
            
            let config = FTS5Config()
                .column(utcDate, [.unindexed])
                .column(moodPointsList, [.unindexed])
                .column(description)
                .column(uuid, [.unindexed])
            
            /// Setup columns
            try database.run(moodDaysTable.create(.FTS5(config)))
            
            print("Table created")
        }
        catch is Result {
            print("Table exists")
        } catch {
            print("Table create error: \(error) \(type(of: error))")
        }
        
        for (date, moodDay) in moodDays {
            if moodDay.moodDay != nil {
                _ = insert(utcDate: date, moodDay: moodDay.moodDay!)
            }
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
    func insert(utcDate: Date, moodDay: SQMoodDay) -> UUID? {
        guard let database = db else { return nil }
        
        let newUuid = UUID()

        let insert = moodDaysTable.insert(self.utcDate <- utcDate, self.moodPointsList <- SQMoodPointsList(moodPoints: moodDay.moodPoints), self.description <- moodDay.description, self.uuid <- newUuid)
    
        do {
            _ = try database.run(insert)
            moodDays = getAllMoodDays()
            reloadCount += 1
            return newUuid
        } catch {
            print(error)
            return nil
        }
    }

    func getAllMoodDays() -> [Date: SQMoodCalendarDay] {
        var moodDays = [Date: SQMoodCalendarDay]()
        guard let database = db else { return [:] }

        do {
            for entry in try database.prepare(self.moodDaysTable) {
                do {
                    let newDay = SQMoodCalendarDay(utcDate: try entry.get(utcDate), moodDay: SQMoodDay(moodPoints: try entry.get(moodPointsList).moodPoints, description: try entry.get(description)), id: try entry.get(uuid))
                    moodDays[try entry.get(utcDate)] = newDay
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        return moodDays
    }

    func findMoodDay(eventId: UUID) -> SQMoodCalendarDay? {
        var foundMoodDay: SQMoodCalendarDay? = nil
        guard let database = db else { return nil }

        let filter = self.moodDaysTable.filter(uuid == eventId)
        do {
            for m in try database.prepare(filter) {
                foundMoodDay = SQMoodCalendarDay(utcDate: m[utcDate], moodDay: SQMoodDay(moodPoints: m[moodPointsList].moodPoints, description: m[description]), id: m[uuid])
            }
        } catch {
            print(error)
        }
        return foundMoodDay
    }
    
    func findMoodDay(searchUtcDate: Date?) -> SQMoodCalendarDay? {
        
        if searchUtcDate == nil {
            return nil
        }
        
        var foundMoodDay: SQMoodCalendarDay? = nil
        guard let database = db else { return nil }

        let filter = self.moodDaysTable.filter(utcDate == searchUtcDate!)
        do {
            for m in try database.prepare(filter) {
                foundMoodDay = SQMoodCalendarDay(utcDate: m[utcDate], moodDay: SQMoodDay(moodPoints: m[moodPointsList].moodPoints, description: m[description]), id: m[uuid])
            }
        } catch {
            print(error)
        }
        return foundMoodDay
    }
    
    func findMoodDay(searchDescriptionString: String) -> [Date: SQMoodCalendarDay] {
        var moodDays = [Date: SQMoodCalendarDay]()
        guard let database = db else { return [:] }

        let filter = self.moodDaysTable.filter(moodDaysTable.match(searchDescriptionString))
        do {
            for m in try database.prepare(filter) {
                moodDays[m[utcDate]] = SQMoodCalendarDay(utcDate: m[utcDate], moodDay: SQMoodDay(moodPoints: m[moodPointsList].moodPoints, description: m[description]), id: m[uuid])
            }
        } catch {
            print(error)
        }
        return moodDays
    }

    func update(utcDate: Date, moodDay: SQMoodDay) -> Bool {
        guard let database = db else { return false }

        let moodEvent = moodDaysTable.filter(self.utcDate == utcDate)
        do {
            let update = moodEvent.update([
                self.moodPointsList <- SQMoodPointsList(moodPoints: moodDay.moodPoints),
                self.description <- moodDay.description
            ])
            if try database.run(update) > 0 {
                moodDays = getAllMoodDays()
                reloadCount += 1
                return true
            }
        } catch {
            print(error)
        }
        return false
    }
    
    func update(id: UUID, utcDate: Date, moodDay: SQMoodDay) -> Bool {
        guard let database = db else { return false }

        let moodEvent = moodDaysTable.filter(self.utcDate == utcDate)
        do {
            let update = moodEvent.update([
                self.moodPointsList <- SQMoodPointsList(moodPoints: moodDay.moodPoints),
                self.description <- moodDay.description
            ])
            if try database.run(update) > 0 {
                moodDays = getAllMoodDays()
                reloadCount += 1
                return true
            }
        } catch {
            print(error)
        }
        return false
    }

    func delete(uuid: UUID) -> Bool {
        guard let database = db else {
            return false
        }
        do {
            let filter = moodDaysTable.filter(self.uuid == uuid)
            try database.run(filter.delete())
            moodDays = getAllMoodDays()
            reloadCount += 1
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func delete(utcDate: Date?) -> Bool {
        
        if utcDate == nil {
            return false
        }
        
        guard let database = db else {
            return false
        }
        do {
            let filter = moodDaysTable.filter(self.utcDate == utcDate!)
            try database.run(filter.delete())
            moodDays = getAllMoodDays()
            reloadCount += 1
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func saveBackup() {

        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = documentsDir.appendingPathComponent(Self.DIR_MOOD_EVENTS_DB)
            
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let databaseFilePath = dirPath.appendingPathComponent(Self.DB_NAME)
                let databaseBackupPath = dirPath.appendingPathComponent(Date.now.ISO8601Format())
                
                try FileManager.default.copyItem(at: databaseFilePath, to: databaseBackupPath)
                
                
                print("Database backed up sucessfully at: \(databaseBackupPath)")
            } catch {
                print("Database backup error: \(error)")
            }
        } else {
            print("Documents directory unknown")
        }
    }
    
}

