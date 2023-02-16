//
//  TodayView.swift
//  Moodient
//
//  Created by Smay on 2/4/23.
//

import SwiftUI
import NaiveDate

struct TodayView: View {
    
    /// Env variables
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject private var moodDays = MoodEventStorage.moodEventStore
    
    /// Keep track of the state of the screen
    @State var id: Int? = nil
    @State var date: Date = Date.now
    @State var moodValue: Int = 0
    @State var description: String = ""

    @State var showingDateErrorAlert = false
    
    @FocusState var textBoxFocused
    
    /// Calculates the mood day to insert into the database
    var convertedMoodDay: MoodDay {
        MoodDay(moodPoints: [MoodPoint(utcTime: Date.now.convertedUtcDate ?? Date.now, moodValue: moodValue)], description: description)
    }
    
    var body: some View {
        
        NavigationView {
            /// UI with a gradient background
            ZStack {
                
                LinearGradient(colors: [.gray.opacity(0.1), MoodOptions.options.moodColors[moodValue].opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                /// Foreground UI
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        Text(date.formatted(date: .complete, time: .omitted))
                            .padding()
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        /// Fake form row (can't use Form because it doesn't avoid the keyboard)
                        HStack {
                            
                            Text("Mood")
                            
                            Spacer()
                            
                            Picker("Mood", selection: $moodValue) {
                                ForEach(0..<5) { value in
                                    Text(MoodOptions.options.moodLabels[value])
                                }
                            }
                            .tint(.secondary)
                            /// Update database when moodValue is changed
                            .onChange(of: moodValue) { newValue in
                                
                                if date.convertedUtcDate == nil || id == nil {
                                    
                                    showingDateErrorAlert.toggle()
                                    return
                                }
                                
                                _ = MoodEventStorage.moodEventStore.update(id: id!, utcDate: date.convertedUtcDate!, moodDay: convertedMoodDay)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                   
                        TextField("Description", text: $description, axis: .vertical)
                            .padding()
                            .background(.ultraThickMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                            .padding(.bottom)
                            .focused($textBoxFocused)
                            /// Update database when the text is changed
                            .onChange(of: description) { newValue in
                                
                                if date.convertedUtcDate == nil || id == nil {
                                    
                                    showingDateErrorAlert.toggle()
                                    
                                    return
                                }
                                
                                _ = MoodEventStorage.moodEventStore.update(id: id!, utcDate: date.convertedUtcDate!, moodDay: convertedMoodDay)
                            }
                        
                        Spacer()
                    }
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), radius: 15)
                }
                
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {

                    Spacer()

                    Button("Done") {
                        textBoxFocused = false
                    }
                    .padding(4)
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )

                        .fill(Color(hue: 0, saturation: 0, brightness: 0.9))
                    )

                }
            }
            /// Save error alert
            .alert("There was an error saving the entry for today", isPresented: $showingDateErrorAlert) {
                Button("Ok") { }
            } message: {
                Text("This really shouldn't happen and if it does something has gone very wrong. Please report this bug")
            }
            /// Reload date and such when UI loads
            .onAppear() {
                
                id = nil
                date = Date.now
                moodValue = 0
                description = ""
                
                if date.convertedUtcDate == nil {
                    return
                }
                
                var today: MoodCalendarDay? = MoodEventStorage.moodEventStore.findMoodDay(searchUtcDate: date.convertedUtcDate)
                
                if today == nil {
                    
                    id = MoodEventStorage.moodEventStore.insert(utcDate: date.convertedUtcDate!, moodDay: convertedMoodDay)
                    today = MoodEventStorage.moodEventStore.findMoodDay(searchUtcDate: date.convertedUtcDate)
                    
                } else {
                    
                    id = today!.id
                }
                
                moodValue = today?.moodDay?.moodPoints[0].moodValue ?? 0
                description = today?.moodDay?.description ?? ""
                
            }
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
