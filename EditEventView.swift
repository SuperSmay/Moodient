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
    
    @State var id: Int = -1
    
    @State var date: Date
    @State var dateOpenedTo: Date?
    @State var moodValue: Int
    @State var description: String
    
    @State var showingDateConflictAlert = false
    
    @FocusState var textBoxFocused
    
    var convertedNaiveDate: NaiveDate {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year ?? 0
        let month = components.month ?? 1
        let day = components.day ?? 1
        
        return NaiveDate(year: year, month: month, day: day)
    }
    
    var convertedDateOpenedTo: NaiveDate? {
        
        if dateOpenedTo == nil {
            return nil
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: dateOpenedTo!)
        
        let year = components.year ?? 0
        let month = components.month ?? 1
        let day = components.day ?? 1
        
        return NaiveDate(year: year, month: month, day: day)
    }
    
    var convertedMoodDay: MoodDay {
        MoodDay(moodPoints: [MoodPoint(naiveTime: NaiveTime(), moodValue: moodValue)], description: description)
    }
    
    
    private let startDateRange = Calendar.current.date(byAdding: .year, value: -100, to: Date.now) ?? Date.distantPast
    
    init(id: Int, naiveDate: NaiveDate?, moodValue: Int, description: String) {
        
        var initialDate = Date.now
        if naiveDate != nil {
            initialDate = Calendar.current.date(from: naiveDate!) ?? Date.now
        }
        
        self._id = State(initialValue: id)
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
                        Button("Done") {
                            
                            let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: convertedNaiveDate)
                            
                            if moodEvent != nil && convertedNaiveDate != convertedDateOpenedTo {
                                
                                showingDateConflictAlert.toggle()
                                
                            } else {
                                
                                if (moodEvent == nil) {
                                    _ = MoodEventStorage.moodEventStore.insert(naiveDate: self.convertedNaiveDate, moodDay: self.convertedMoodDay)
                                } else {
                                    _ = MoodEventStorage.moodEventStore.update(id: moodEvent?.id ?? -1, naiveDate: self.convertedNaiveDate, moodDay: self.convertedMoodDay)
                                    
                                }
                                
                                if convertedNaiveDate != convertedDateOpenedTo {
                                    _ = MoodEventStorage.moodEventStore.delete(naiveDate: convertedDateOpenedTo)
                                }
                                
                                dismiss()
                                
                            }
                            
                            
                            
                            
                            
                        }
                        .alert("You already have an entry on that day", isPresented: $showingDateConflictAlert) {
                            Button("Overwrite", role: .destructive) {
                                
                                let moodEvent = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: convertedNaiveDate)
                                
                                _ = MoodEventStorage.moodEventStore.update(id: moodEvent?.id ?? -1, naiveDate: self.convertedNaiveDate, moodDay: self.convertedMoodDay)
                                
                                if convertedNaiveDate != convertedDateOpenedTo {
                                    _ = MoodEventStorage.moodEventStore.delete(naiveDate: convertedDateOpenedTo)
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
        EditEventView(id: -1, naiveDate: NaiveDate(year: 2022, month: 1, day: 1), moodValue: 0, description: "")
    }
}
