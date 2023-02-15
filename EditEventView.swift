//
//  AddNewDayView.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI
import NaiveDate

struct EditEventView: View {
    
    /// Env variables
    @Environment (\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    /// Keep track of the state of the screen
    @State var date: Date
    @State var dateOpenedTo: Date?
    @State var moodValue: Int
    @State var description: String
    
    @State var showingDateConflictAlert = false
    @State var showingDateErrorAlert = false
    
    /// Focus state of the description box, to allow for a done button
    @FocusState var textBoxFocused
    
    /// Calculates the mood day to insert into the database
    var convertedMoodDay: MoodDay {
        MoodDay(moodPoints: [MoodPoint(naiveTime: NaiveTime(), moodValue: moodValue)], description: description)
    }
    
    /// Initializes the date, mood value, and description
    init(utcDate: Date?, moodValue: Int, description: String) {
        
        var initialDate = Date.now
        
        if utcDate != nil {
            initialDate = utcDate!.convertedCurrentTimezoneDate ?? Date.now
        }
   
        self._date = State(initialValue: initialDate)
        
        if utcDate != nil {
            self._dateOpenedTo = State(initialValue: initialDate)
        }
        
        self._moodValue = State(initialValue: moodValue)
        self._description = State(initialValue: description)
    }
    
    var body: some View {
        
        NavigationView {
            /// UI with a gradient background
            ZStack {
                
                LinearGradient(colors: [.gray.opacity(0.1), MoodOptions.options.moodColors[moodValue].opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                /// Foreground UI
                VStack(alignment: .leading) {
                    
                    /// Fake form thing  (can't use Form because it doesn't avoid the keyboard)
                    VStack {
                        
                        DatePicker("Date", selection: $date, in: Date.distantPast...Date.now, displayedComponents: .date)
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(.thinMaterial)
                        
                        HStack {
                            Text("Mood")
                            Spacer()
                            Picker("Mood", selection: $moodValue) {
                                ForEach(0..<5) { value in
                                    Text(MoodOptions.options.moodLabels[value])
                                }
                            }
                            .tint(.secondary)
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
                        
                    
                    Spacer()
                }
                .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), radius: 15)

            }
            .navigationTitle (date.formatted(date: .abbreviated, time: .omitted))
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
                        
                        
                        let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchUtcDate: date.convertedUtcDate)
                        
                        if date != dateOpenedTo && moodEvent?.utcDate == date.convertedUtcDate {
                            
                            showingDateConflictAlert.toggle()
                            
                            return
                            
                        }
                        
                        if date.convertedUtcDate == nil {
                            showingDateErrorAlert.toggle()
                            return
                        }
                        
                        if moodEvent == nil {
                            _ = MoodEventStorage.moodEventStore.insert(utcDate: date.convertedUtcDate!, moodDay: self.convertedMoodDay)
                        } else {
                            _ = MoodEventStorage.moodEventStore.update(id: moodEvent!.id, utcDate: date.convertedUtcDate!, moodDay: self.convertedMoodDay)
                            
                        }
                        
                        if date != dateOpenedTo {
                            _ = MoodEventStorage.moodEventStore.delete(utcDate: dateOpenedTo?.convertedUtcDate)
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
                    
                    let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchUtcDate: date.convertedUtcDate)
                    
                    if moodEvent == nil {
                        return
                    }
                    
                    if date.convertedUtcDate == nil {
                        showingDateErrorAlert.toggle()
                        return
                    }
                    
                    _ = MoodEventStorage.moodEventStore.update(id: moodEvent!.id, utcDate: date.convertedUtcDate!, moodDay: self.convertedMoodDay)
                    
                    if date != dateOpenedTo {
                        _ = MoodEventStorage.moodEventStore.delete(utcDate: dateOpenedTo?.convertedUtcDate)
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
        EditEventView(utcDate: Date.now.convertedUtcDate, moodValue: 0, description: "")
    }
}
