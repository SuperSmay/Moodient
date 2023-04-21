//
//  MoodEventCoreData.swift
//  Moodient
//
//  Created by Smay on 4/20/23.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "MoodDays")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading CoreData: \(error.localizedDescription)")
            }
        }
    }
    
}


public class MoodDay: NSManagedObject {
    
    @NSManaged public var utcDate: Date?
    @NSManaged public var dayDescription: String?
    @NSManaged public var id: UUID
    
    @NSManaged var moodPoints: [MoodPoint]?
}

extension MoodDay: Identifiable {

}

public class MoodPoint: NSObject, NSSecureCoding {
    
    public required init?(coder: NSCoder) {
            // NSCoding
            //name = coder.decodeObject(forKey: "name") as? String ?? ""
            //last_name = coder.decodeObject(forKey: "last_name") as? String ?? ""

            // NSSecureCoding
        utcTime = coder.decodeObject(of: NSDate.self, forKey: "utcTime") as Date? ?? Date.now
        moodValue = coder.decodeInteger(forKey: "moodValue")
        }

        public func encode(with coder: NSCoder) {
            coder.encode(utcTime, forKey: "utcTime")
            coder.encode(moodValue, forKey: "moodValue")
        }
    
    public static var supportsSecureCoding: Bool = true

    var utcTime: Date
    var moodValue: Int
    var id = UUID()
    
    init(utcTime: Date, moodValue: Int) {
        self.utcTime = utcTime
        self.moodValue = moodValue
    }
}
