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
            VStack {
                List {
                    ForEach(moodDays) { day in
                        
                        let naiveDate: NaiveDate = day.naiveDate
                        let date = Calendar.current.date(from: naiveDate) ?? Date.now
                        let moodValue = day.moodDay?.moodPoints.first?.moodValue
                        
                        HStack {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                
                                
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                            
                        }
                        .contentShape(Rectangle())
                        .listRowBackground(
                            LinearGradient(colors: [colorScheme == .light ? Color.white : Color.gray.opacity(0.1), MoodOptions().colors[moodValue ?? 0].swiftuiColor.opacity(0.2)], startPoint: .center, endPoint: .trailing)
                        )
                        .onTapGesture {
                            if editSheetMoodDay == nil {
                                editSheetMoodDay = day
                                editSheetShowing.toggle()
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                editSheetMoodDay = day
                                editSheetShowing.toggle()
                                
                            }, label: {
                                Label("Edit", systemImage: "pencil")
                            })
                        } preview: {
                            
                            DayPreview(id: day.id)
                            
                        }
                    }
                    .onDelete(perform: removeRows)
                    
                }
                .sheet(item: self.$editSheetMoodDay, onDismiss: {
                    reload()
                    editSheetMoodDay = nil
                }) { day in
                    EditEventView(id: day.id, naiveDate: day.naiveDate, moodValue: day.moodDay?.moodPoints[0].moodValue ?? 0, description: day.moodDay?.description ?? "")
                }
                
                
                
                
            }
            .toolbar {
                HStack {
                    Button {
                        newSheetShowing.toggle()
                    } label: {
                        Image(systemName: "plus")
//                        Text("Add New")
//                            .bold()
//                            .padding()
//                            .background(.secondary)
//                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .sheet(isPresented: $newSheetShowing, onDismiss: {
                        reload()
                        editSheetMoodDay = nil
                    })
                    {
                        EditEventView(id: -1, naiveDate: nil, moodValue: 0, description: "")
                    }
                    
                    
                    
                    
//                    Button(role: .destructive, action: {
//                        MoodEventStorage.moodEventStore.deleteTable()
//                        reload()
//                    }, label: {
//                        Text("Drop table")
//                            .bold()
//                            .padding()
//                            .background(.secondary)
//                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                    })
                    
                }
            }
            .navigationTitle("Moodient")
            .onAppear() {
                reload()
            }
        }
        
    }
    
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

struct DayListView_Previews: PreviewProvider {
    static var previews: some View {
        DayListView()
    }
}
