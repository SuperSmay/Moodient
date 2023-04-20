//
//  AddNewDayView.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI

struct EditEventView: View {
    
    /// Env variables
    @Environment (\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    /// These are supposedly expensive to make, so we will avoid making tons of them
    @Environment(\.utcDateFormatter) var utcDateFormatter
    
    /// Pull moodDays from the environment
    @ObservedObject private var moodDays = MoodEventStorage.moodEventStore
    
    /// Keep track of the state of the screen
    @State var utcDate: Date
    @State var utcDateOpenedTo: Date?
    @State var moodPoints: [MoodPoint]
    
    @State var description: String
    
    @State var showingDateConflictAlert = false
    @State var showingDateErrorAlert = false
    
    /// Focus state of the description box, to allow for a done button
    @FocusState var textBoxFocused
    
    /// Calculates the mood day to insert into the database
    var convertedMoodDay: MoodDay {
        MoodDay(moodPoints: moodPoints, description: description)
    }
    
    /// Initializes the date, mood value, and description
    init(utcDate: Date, moodPoints: [MoodPoint], description: String) {
   
        self._utcDate = State(initialValue: utcDate)
        self._moodPoints = State(initialValue: moodPoints)
        self._description = State(initialValue: description)
        
    }
    
    var body: some View {
        
        
        
        NavigationView {
            /// UI with a gradient background
            ZStack {
                
                BackgroundGradient(moodPoints: moodPoints)
                    .zIndex(-2)
                    .ignoresSafeArea()
                    .opacity(0.25)
                    
                
                /// Foreground UI
                VStack(alignment: .leading) {
                    
                    /// Fake form thing  (can't use Form because it doesn't avoid the keyboard)
                    /// Is a scuffed stack with a background because if I use clip shape then the little mood time things are clipped when dragged outside the box
                    VStack {
                        
                        DatePicker("Date", selection: $utcDate, in: Date.distantPast...Date.now, displayedComponents: .date)
                            .environment(\.timeZone, TimeZone.gmt)
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(.thinMaterial)
                        
                        MoodTimelineControlView(moodPoints: $moodPoints)
                            .zIndex(10)
                            .frame(maxHeight: 100)
                            .padding(.bottom)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background {
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(.ultraThickMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), radius: 15)

                            
                    }
                    
                    .padding()
                    
                             
                    TextField("Description", text: $description, axis: .vertical)
                        .zIndex(-1)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        .padding(.bottom)
                        .focused($textBoxFocused)
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), radius: 15)

    
                    
                    Spacer()
                }
                
            }
            .navigationTitle(utcDateFormatter.string(from: utcDate))
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            
            // Keyboard done button
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
            // Save and cancel buttons
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        
                        
                        let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchUtcDate: utcDate)
                        
                        if utcDate != utcDateOpenedTo && moodEvent?.utcDate == utcDate {
                            
                            showingDateConflictAlert.toggle()
                            
                            return
                            
                        }

                        if moodEvent == nil {
                            _ = MoodEventStorage.moodEventStore.insert(utcDate: utcDate, moodDay: self.convertedMoodDay)
                        } else {
                            _ = MoodEventStorage.moodEventStore.update(id: moodEvent!.id, utcDate: utcDate, moodDay: self.convertedMoodDay)
                            
                        }
                        
                        if utcDate != utcDateOpenedTo {
                            _ = MoodEventStorage.moodEventStore.delete(utcDate: utcDateOpenedTo)
                        }
                        
                        dismiss()

                    }
                    
                    
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            // Overwrite alert
            .alert("You already have an entry on that day", isPresented: $showingDateConflictAlert) {
                Button("Overwrite", role: .destructive) {
                    
                    let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchUtcDate: utcDate)
                    
                    if moodEvent == nil {
                        return
                    }
                    
                    _ = MoodEventStorage.moodEventStore.update(id: moodEvent!.id, utcDate: utcDate, moodDay: self.convertedMoodDay)
                    
                    if utcDate != utcDateOpenedTo {
                        _ = MoodEventStorage.moodEventStore.delete(utcDate: utcDateOpenedTo)
                    }

                    dismiss()
                    
                }
            }
            // Very bad error alert
            .alert("There was an error saving to that date", isPresented: $showingDateErrorAlert) {
                Button("Ok") { }
            } message: {
                Text("Please try a different day")
            }
        }
    }
}

struct EditEventView_Preview: PreviewProvider {
    static var previews: some View {
        EditEventView(utcDate: Date.now.convertedUtcDate!, moodPoints: [], description: "")
    }
}
