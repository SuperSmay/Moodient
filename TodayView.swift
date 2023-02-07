//
//  TodayView.swift
//  Moodient
//
//  Created by Smay on 2/4/23.
//

import SwiftUI
import NaiveDate

struct TodayView: View {
    
    @State var date: Date = Date.now
    @State var moodValue: Int = 0
    @State var description: String = ""
    
    @FocusState var textBoxFocused
    
    @State var id: Int? = nil
    
    @State var today: MoodCalendarDay? = nil
    
    var convertedNaiveDate: NaiveDate {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year ?? 0
        let month = components.month ?? 1
        let day = components.day ?? 1
        
        return NaiveDate(year: year, month: month, day: day)
    }
    
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
                    
                        
                    
                        .focused($textBoxFocused)
                        .onChange(of: description) { newValue in
                            _ = MoodEventStorage.moodEventStore.update(id: id ?? -1, naiveDate: convertedNaiveDate, moodDay: convertedMoodDay)
                        }
                        .lineLimit(10)
                    
                    
                        .onChange(of: moodValue) { newValue in
                            _ = MoodEventStorage.moodEventStore.update(id: id ?? -1, naiveDate: convertedNaiveDate, moodDay: convertedMoodDay)
                        }
                    
                    Spacer()
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
            .onAppear() {
                
                date = Date.now
                
                today = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: convertedNaiveDate)
                if today == nil {
                    id = MoodEventStorage.moodEventStore.insert(naiveDate: convertedNaiveDate, moodDay: convertedMoodDay)
                    today = MoodEventStorage.moodEventStore.findMoodDay(searchNaiveDate: convertedNaiveDate)
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
