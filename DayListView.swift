//
//  DayListView.swift
//  Moodient
//
//  Created by Smay on 2/4/23.
//

import SwiftUI
import NaiveDate

struct DayListView: View {
    
    @State var moodDays = MoodEventStorage.moodEventStore.getAllMoodDays()
    @State private var editSheetShowing = false
    @State private var editSheetMoodDay: MoodCalendarDay? = nil
    @State private var newSheetShowing = false
    
    @State private var presentedViewIDs = [Int]()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationStack(path: $presentedViewIDs) {
            
            List {
                    
                ForEach(moodDays) { day in
                        
                    let date = day.utcDate.convertedCurrentTimezoneDate ?? Date.now
                        let moodValue = day.moodDay?.moodPoints.first?.moodValue
                        
                        Button {
                            if editSheetMoodDay == nil {
                                editSheetMoodDay = day
                                editSheetShowing.toggle()
                            }
                        } label: {
                            HStack {
                                
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            
                            }
                        }
                        .tint(.primary)
                        .listRowBackground(
                            
                            LinearGradient(stops: [.init(color: colorScheme == .light ? Color.white : Color.gray.opacity(0.1), location: 0.25), .init(color: MoodOptions.options.moodColors[moodValue ?? 0].opacity(0.5), location: 1)], startPoint: .leading, endPoint: .trailing)
         
                        )
                        .contextMenu {
                            Button(action: {
                                editSheetMoodDay = day
                                editSheetShowing.toggle()
                                
                            }, label: {
                                Label("Edit", systemImage: "pencil")
                            })
                        }
                    }
                    .onDelete(perform: removeRows)
                    
                }
            .sheet(item: self.$editSheetMoodDay, onDismiss: {
                reload()
                editSheetMoodDay = nil
            }) { day in
                EditEventView(utcDate: day.utcDate.convertedCurrentTimezoneDate, moodValue: day.moodDay?.moodPoints[0].moodValue ?? 0, description: day.moodDay?.description ?? "")
            }
            .navigationTitle("Moodient")
            /// Reload from database when UI loads
            .onAppear() {
                reload()
            }
            /// Add new item button
            .toolbar {
                HStack {
                    Button {
                        newSheetShowing.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $newSheetShowing, onDismiss: {
                        reload()
                        editSheetMoodDay = nil
                    })
                    {
                        EditEventView(utcDate: nil, moodValue: 0, description: "")
                    }
                }
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

//extension Int: Identifiable {
//    public var id: Int { return self }
//}

struct DayListView_Previews: PreviewProvider {
    static var previews: some View {
        DayListView()
    }
}
