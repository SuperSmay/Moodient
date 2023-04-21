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
