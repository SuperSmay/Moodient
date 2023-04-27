//
//  TodayView.swift
//  Moodient
//
//  Created by Smay on 2/4/23.
//

import SwiftUI

struct TodayView: View {
    
    /// Env variables
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    /// Keep track of the state of the screen
    @State var utcDate: Date?
    @State var moodPoints: [MoodPoint] = []
    @State var description: String = ""
    
    @State var moodDay: MoodDay?

    @State var showingDateErrorAlert = false
    
    @FocusState var textBoxFocused
    
    @State private var waitingForSave = false
    
    var completeUtcDateFormatter:  DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.gmt
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
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
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        Text(completeUtcDateFormatter.string(from: utcDate ?? Date.now))
                            .padding()
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        /// Fake form row (can't use Form because it doesn't avoid the keyboard)
                        MoodTimelineControlView(moodPoints: $moodPoints)
                            .zIndex(10)
                            .frame(height: 100)
                            .padding()
                            .background {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .background(.ultraThickMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), radius: 15)
                            }
                            .padding()
                            .onChange(of: moodPoints) { _ in
                                
                                save()
                                
                            }
                        
                        TextField("Description", text: $description, axis: .vertical)
                            .padding()
                            .background(.ultraThickMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                            .padding(.bottom)
                            .focused($textBoxFocused)
                            .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), radius: 15)
                            /// Update database when the text is changed
                            .onChange(of: description) { _ in
                                
                               save()
                                
                            }
                        
                        Spacer()
                    }
                    
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
            
            
        }
        /// Reload date and such when UI loads
        .onAppear() {
            
            if let utcDate = Date.now.convertedUtcDate {
                
                self.utcDate = utcDate
                
                let fetchRequest = MoodDay.fetchRequest()
                let predicate = NSPredicate(format: "utcDate == %@", utcDate as CVarArg)
                fetchRequest.predicate = predicate
                fetchRequest.includesPropertyValues = false
                
                let result = try? moc.fetch(fetchRequest)
                
                
                if let firstMoodDay = result?.first as? MoodDay {
                    moodDay = firstMoodDay
                    description = moodDay?.dayDescription ?? ""
                    moodPoints = moodDay?.moodPoints ?? []
                } else {
                    let newMoodDay = MoodDay(context: moc)
                    newMoodDay.utcDate = utcDate
                    newMoodDay.dayDescription = ""
                    newMoodDay.moodPoints = []
                    moodDay = newMoodDay
                }
 
            } else {
                print("Ruh roh utcDate is nil in TodayView onAppear")
                description = ""
                moodPoints = []
                showingDateErrorAlert.toggle()
                
            }
        }
        
        
        
    }
    
    /// Simple batched updates
    func save() {
        
        guard !waitingForSave else { return }
        waitingForSave = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if utcDate == nil || moodDay == nil {
                
                print("Save failed: utcDate:\(String(describing: utcDate)), moodDay: \(String(describing: moodDay)), date: \(Date.now)")
                
                showingDateErrorAlert.toggle()
                
                return
            }
            
            moodDay?.utcDate = utcDate
            moodDay?.dayDescription = description
            moodDay?.moodPoints = moodPoints
            
            do {
                try moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
            
            waitingForSave = false
            
            if moodDay?.utcDate != utcDate || moodDay?.dayDescription != description || moodDay?.moodPoints != moodPoints {
                save()
            }
            
        }
    }
    
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
