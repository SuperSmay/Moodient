//
//  MonthDayView.swift
//  Moodient
//
//  Created by Smay on 2/9/23.
//

import SwiftUI
import NaiveDate

struct MonthDayView: View {
    
    /// Light/dark mode
    @Environment(\.colorScheme) var colorScheme
    /// The size of the window this view is being displayed in
    @Environment(\.mainWindowSize) var mainWindowSize
    /// This is a bit scuffed, but is used to check if this view is being displayed and should respond to the shake easteregg
    @Environment(\.selectedTabTitle) var selectedTabeTitle
    
    /// Sheets for creating/editing entries
    @State private var editSheetShowing = false
    @State private var newSheetShowing = false
    
    /// The moodCalenderDay for this date, loaded from the database
    @State var moodCalenderDay: MoodCalendarDay? = nil
    
    /// Falling easteregg things
    @State private var animationAmount = 0.0
    @State private var willFallCount = 0
    @State private var didFall = false;
    
    /// The actual date
    let utcDate: Date
    
    
    
    var body: some View {
        
        /// Display things
        let moodValue: Int? = moodCalenderDay?.moodDay?.moodPoints[0].moodValue
        let moodColor = MoodOptions.options.moodColors[moodValue ?? 0]
        
        GeometryReader { geo in

            /// The whole date icon
            ZStack {
                
                /// Background for after they fall
                RoundedRectangle(cornerRadius: geo.size.width * 0.2, style: .continuous)
                    .foregroundColor(
                        Color.secondary.opacity(0.25)
                    )
                
                /// The normal view
                ZStack {
                        
                        RoundedRectangle(cornerRadius: geo.size.width * 0.2, style: .continuous)
                        
                            .foregroundColor(
                                moodValue == nil ? Color.secondary.opacity(0.25) : moodColor
                            )
                        
                    let components = Calendar.autoupdatingCurrent.dateComponents([.day], from: utcDate.convertedCurrentTimezoneDate ?? Date.now)
                        
                        Text(String(components.day ?? 1))
                    
//                    VStack {
//                        Text(String(TimeZone.current.secondsFromGMT()/3600))
//                        Text(utcDate.ISO8601Format())
//                        Text(utcDate.convertedCurrentTimezoneDate!.ISO8601Format())
//                        Text(utcDate.convertedUtcDate!.ISO8601Format())
//                    }
                    
                        
                            .font(.system(size: geo.size.width * 0.75, design: .rounded))
                        
                            .bold()
                        //.foregroundStyle(.thinMaterial)
                            .foregroundColor(colorScheme == .light ? .white.opacity(0.65) : .black.opacity(0.45))
                        
                    }
                    /// Fun things
                    .onTapGesture {
                        doAnimation()
                    }
                    /// The real easteregg
                    .onShake {
                        
                        /// Hardcoded and kinda bad, but works for now
                        if selectedTabeTitle != "Day List" || didFall {
                            return
                        }
                        
                        /// Run the animation after a random delay
                        let randomDelay = Double.random(in: 0.0..<0.4)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                            /// Increment to make some of the icons fall after shaking
                            willFallCount += 1
                            let fallRandom = Double.random(in: 0..<1)
                            if willFallCount != 1 && fallRandom < Double((willFallCount * 10))/100.0 {
                                didFall = true
                            }
                            doAnimation()
                        }

                    }
                    ///
                    /// Fun animation stuff
                    ///
                    
                    .offset(y: didFall ? mainWindowSize.height + geo.size.height * 3 - geo.frame(in: .global).origin.y : 0)
                    .animation(didFall ? .easeIn(duration: 4) : .easeIn(duration: 2), value: didFall)
            }
            ///
            /// More fun animation stuff (Down here so that the background rotates too)
            ///
            .rotationEffect(Angle.degrees(animationAmount))
            .animation(
                didFall ? .spring(response: 2, dampingFraction: 0.2, blendDuration: 2) : .spring(dampingFraction: 0.2),
                value: animationAmount
            )
                
            
            
        }
        /// Keep the thing locked to a square
        .aspectRatio(1, contentMode: .fit)
        /// Reset animation and reload database data
        .onAppear() {
            didFall = false
            willFallCount = 0
            reload()
        }
        /// Touch and hold menu
        .contextMenu {
            /// If the date should be able to be edited, then show the edit button
            if (Date.now.convertedUtcDate != nil && utcDate <= Date.now.convertedUtcDate!) {
                Button(action: {
                    if moodCalenderDay?.moodDay == nil {
                        newSheetShowing.toggle()
                    } else {
                        editSheetShowing.toggle()
                    }

                }, label: {
                    Label("Edit", systemImage: "pencil")
                })
            /// Otherwise, show a disabled button (Text doesn't work so this was the best option) that has a fun message
            } else {

                let daysAway = (Calendar.autoupdatingCurrent.dateComponents([.day], from: Date.now.convertedUtcDate ?? Date.now, to: utcDate).day ?? -1)
                let daysAwayText = daysAway == 1 ? "tomorrow!" : "\(daysAway) days from now"
                Button("That's \(daysAwayText)") {}
                    .disabled(true)
            }
            
        }
        /// Edit sheet
        .sheet(isPresented: $editSheetShowing, onDismiss: {
            reload()
        }) {
            /// Force unwraps ok because that value is checked for nil before this sheet is presented
            EditEventView(utcDate: moodCalenderDay!.utcDate, moodValue: moodCalenderDay!.moodDay?.moodPoints[0].moodValue ?? 0, description: moodCalenderDay!.moodDay?.description ?? "")
        }
        /// Edit sheet but when there wasn't already an entry
        .sheet(isPresented: $newSheetShowing, onDismiss: {
            reload()
        })
        {
            EditEventView(utcDate: utcDate, moodValue: 0, description: "")
        }
        
        
    }
    
    /// Adjusts the animation values and does the haptics
    func doAnimation() {
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        if animationAmount == 0 {
            animationAmount += Double.random(in: -45..<45)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animationAmount = 0
            }
        }
    }
    
    func reload() {
        moodCalenderDay = MoodEventStorage.moodEventStore.findMoodDay(searchUtcDate: utcDate)
    }
    
}

struct MonthDayView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            MonthDayView(utcDate: Date.now.convertedUtcDate ?? Date.now)
                .environment(\.mainWindowSize, geo.size)
        }
    }
}
