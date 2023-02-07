//
//  TodayView.swift
//  Moodient
//
//  Created by Smay on 2/4/23.
//

import SwiftUI
import NaiveDate

struct TodayView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var id: Int? = nil
    @State var date: Date = Date.now
    @State var moodValue: Int = 0
    @State var description: String = ""

    @State var showingDateErrorAlert = false
    
    @FocusState var textBoxFocused
    

    var convertedMoodDay: MoodDay {
        MoodDay(moodPoints: [MoodPoint(naiveTime: NaiveTime(), moodValue: moodValue)], description: description)
    }
    
    
    private let startDateRange = Calendar.current.date(byAdding: .year, value: -100, to: Date.now) ?? Date.distantPast
    
    var body: some View {
        NavigationView {
            
            ZStack {
                LinearGradient(colors: [.gray.opacity(0.1), MoodOptions().colors[moodValue].swiftuiColor.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                
                
                VStack(alignment: .leading) {
                    
                    
                    Text(date.formatted(date: .complete, time: .omitted))
                        .padding()
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    
                    
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
                        .onChange(of: description) { newValue in
                            
                            if date.convertedNaiveDate == nil || id == nil {
                                
                                showingDateErrorAlert.toggle()
                                
                                return
                            }
                            
                            _ = MoodEventStorage.moodEventStore.update(id: id!, naiveDate: date.convertedNaiveDate!, moodDay: convertedMoodDay)
                        }
                        
                        .alert("There was an error saving the entry for today", isPresented: $showingDateErrorAlert) {
                            
                            Button("Ok") { }
                        } message: {
                            Text("This really shouldn't happen and if it does something has gone very wrong. Please report this bug")
                        }
                    
                        .onChange(of: moodValue) { newValue in
                            
                            if date.convertedNaiveDate == nil || id == nil {
                                
                                showingDateErrorAlert.toggle()
                                
                                return
                            }
                            
                            _ = MoodEventStorage.moodEventStore.update(id: id!, naiveDate: date.convertedNaiveDate!, moodDay: convertedMoodDay)
                        }
                    
                    Spacer()
                }
                .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), radius: 15)
                
                
                
                
                
                
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
            .onAppear() {
                
                id = nil
                date = Date.now
                moodValue = 0
                description = ""
                
                if date.convertedNaiveDate == nil {
                    return
                }
                
                var today: MoodCalendarDay? = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: date.convertedNaiveDate)
                
                if today == nil {
                    
                    id = MoodEventStorage.moodEventStore.insert(naiveDate: date.convertedNaiveDate!, moodDay: convertedMoodDay)
                    today = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: date.convertedNaiveDate)
                    
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
