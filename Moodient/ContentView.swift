//
//  ContentView.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI
import NaiveDate

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "clock")
                }
            
            DayListView()
                .tabItem {
                    Label("Day List", systemImage: "calendar")
                }
                
            
//            NavigationStack(path: $presentedViewIDs) {
//                VStack {
//                    List {
//                        ForEach(moodDays) { day in
//
//                            let naiveDate: NaiveDate = day.naiveDate
//                            let date = Calendar.current.date(from: naiveDate) ?? Date.now
//                            let moodValue = day.moodDay?.moodPoints.first?.moodValue
//
//                            Text(date.formatted(date: .abbreviated, time: .omitted))
//                                .listRowBackground(
//                                    LinearGradient(colors: [colorScheme == .light ? Color.white : Color.gray.opacity(0.1), MoodOptions().colors[moodValue ?? 0].swiftuiColor.opacity(0.2)], startPoint: .center, endPoint: .trailing)
//                                )
//                                .contextMenu {
//                                    Button(action: {
//                                        editSheetID = day.id
//                                        editSheetShowing.toggle()
//                                    }, label: {
//                                        Label("Edit", systemImage: "pencil")
//                                    })
//                                } preview: {
//
//                                    DayPreview(id: day.id)
//
//                                }
//
//                        }
//
//                        .onDelete(perform: removeRows)
//
//                    }
//
//
//                    HStack {
//                        Button {
//                            editSheetID = -1
//                            editSheetShowing.toggle()
//                        } label: {
//                            Text("Add New")
//                                .bold()
//                                .padding()
//                                .background(.secondary)
//                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                        }
//                        .sheet(isPresented: $editSheetShowing, onDismiss: reload) {
//                            EditEventView(id: editSheetID)
//                        }
//
//
//                        Button(role: .destructive, action: {
//                            MoodEventStorage.moodEventStore.deleteTable()
//                            reload()
//                        }, label: {
//                            Text("Drop table")
//                                .bold()
//                                .padding()
//                                .background(.secondary)
//                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                        })
//
//                    }
//                }
//            }
//            .navigationTitle("Moodient")
        }
    }
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
