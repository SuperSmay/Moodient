//
//  AddNewDayView.swift
//  Moodient
//
//  Created by Smay on 2/2/23.
//

import SwiftUI
import NaiveDate

struct EditEventView: View {
    
    @Environment (\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State var date: Date
    @State var dateOpenedTo: Date?
    @State var moodValue: Int
    @State var description: String
    
    @State var showingDateConflictAlert = false
    
    @FocusState var textBoxFocused
    
    var convertedMoodDay: MoodDay {
        MoodDay(moodPoints: [MoodPoint(naiveTime: NaiveTime(), moodValue: moodValue)], description: description)
    }
    
    
    private let startDateRange = Calendar.current.date(byAdding: .year, value: -100, to: Date.now) ?? Date.distantPast
    
    init(naiveDate: NaiveDate?, moodValue: Int, description: String) {
        
        var initialDate = Date.now
        if naiveDate != nil {
            initialDate = Calendar.current.date(from: naiveDate!) ?? Date.now
        }
        
        
        self._date = State(initialValue: initialDate)
        if naiveDate != nil {
            self._dateOpenedTo = State(initialValue: initialDate)
        }
        self._moodValue = State(initialValue: moodValue)
        self._description = State(initialValue: description)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                LinearGradient(colors: [.gray.opacity(0.1), MoodOptions().colors[moodValue].swiftuiColor.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                
                VStack(alignment: .leading) {
                    
                    VStack {
                        
                        DatePicker("Date", selection: $date, in: startDateRange...Date.now, displayedComponents: .date)
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(.thinMaterial)
                        
                        HStack {
                            Text("Mood")
                            Spacer()
                            Picker("Mood", selection: $moodValue) {
                                ForEach(0..<5) { value in
                                    Text(MoodOptions().labels[value])
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
                .toolbar() {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            
                            if date.convertedNaiveDate == nil {
                                return
                            }
                            
                            let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: date.convertedNaiveDate!)
                            
                            if date.convertedNaiveDate == dateOpenedTo?.convertedNaiveDate {
                                
                                showingDateConflictAlert.toggle()
                                
                                return
                                
                            }
                            
                            if moodEvent == nil {
                                _ = MoodEventStorage.moodEventStore.insert(naiveDate: date.convertedNaiveDate!, moodDay: self.convertedMoodDay)
                            } else {
                                _ = MoodEventStorage.moodEventStore.update(id: moodEvent!.id, naiveDate: date.convertedNaiveDate!, moodDay: self.convertedMoodDay)
                                
                            }
                            
                            if date.convertedNaiveDate != dateOpenedTo?.convertedNaiveDate {
                                _ = MoodEventStorage.moodEventStore.delete(naiveDate: dateOpenedTo?.convertedNaiveDate)
                            }
                            
                            dismiss()
                            
                            
                            
                            
                            
                            
                            
                        }
                        .alert("You already have an entry on that day", isPresented: $showingDateConflictAlert) {
                            Button("Overwrite", role: .destructive) {
                                
                                let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: date.convertedNaiveDate)
                                
                                if moodEvent == nil {
                                    return
                                }
                                
                                _ = MoodEventStorage.moodEventStore.update(id: moodEvent!.id, naiveDate: date.convertedNaiveDate!, moodDay: self.convertedMoodDay)
                                
                                if date.convertedNaiveDate != dateOpenedTo?.convertedNaiveDate {
                                    _ = MoodEventStorage.moodEventStore.delete(naiveDate: dateOpenedTo?.convertedNaiveDate)
                                }
                                
                                dismiss()
                                
                            }
                            
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
                }
                
                
                
                
            
            
            }
            .navigationTitle (date.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
    }
}

struct EditEventView_Preview: PreviewProvider {
    static var previews: some View {
        EditEventView(naiveDate: NaiveDate(year: 2022, month: 1, day: 1), moodValue: 0, description: "")
    }
}
