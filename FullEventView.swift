//
//  LazyCompleteDayList.swift
//  Moodient
//
//  Created by Smay on 2/8/23.
//

import SwiftUI
import NaiveDate

struct FullEventView: View {
    
    @State var moodDays = MoodEventStorage.moodEventStore.getAllMoodDays()
    @State private var editSheetShowing = false
    @State private var editSheetMoodDay: MoodCalendarDay? = nil
    @State private var newSheetShowing = false
    
    @State private var month = Date.now
    
    @State private var presentedViewIDs = [Int]()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationStack(path: $presentedViewIDs) {
            
            VStack(alignment: .leading) {
                
                let monthIndex = Calendar.current.dateComponents([.month], from: month).month
                
                Text(Calendar.current.monthSymbols[(monthIndex ?? 1) - 1])
                    .padding()
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                MonthView(dayInMonth: Date.now)
                    .padding()
                    .navigationTitle("Moodient")
                
                
                Spacer()
            }
        }
    }
    
    
    /// Callback to delete rows from the database when rows are deleted from the UI
    func removeRows(at offsets: IndexSet) {
        let id = offsets.map { self.moodDays[$0].id }.first

        if let id = id {
            let delete = MoodEventStorage.moodEventStore.delete(id: id)
            if delete {
                reload()
            }
        }
    }
    
    func reload() {
        moodDays = MoodEventStorage.moodEventStore.getAllMoodDays()
    }
    
}

extension Int: Identifiable {
    public var id: Int { return self }
}

struct FullEventView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            FullEventView()
                .environment(\.mainWindowSize, geo.size)
        }
    }
}
