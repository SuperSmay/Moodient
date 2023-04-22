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
    
    @NSManaged public var moodPointsData: String
    
    /// https://stackoverflow.com/a/65550870
    /// Way better than the transformable nonsense
    var moodPoints: [MoodPoint] {
        get {
            return (try? JSONDecoder().decode([MoodPoint].self, from: Data(moodPointsData.utf8))) ?? []
        }
        set {
            
            do {
                let rawMoodPointsData = try JSONEncoder().encode(newValue)
                moodPointsData = String(data: rawMoodPointsData, encoding: .utf8)!
            } catch {
                print("Error encoding moodPoints array \(newValue)")
                moodPointsData = ""
            }
        }
    }
    
}

extension MoodDay: Identifiable {

}

public struct MoodPoint: Codable, Identifiable, Equatable {

    public var utcTime: Date
    public var moodValue: Int
    public var id = UUID()

}
