//
//  MonthDayView.swift
//  Moodient
//
//  Created by Smay on 2/9/23.
//

import SwiftUI

struct MonthDayView: View {
    
    /// Light/dark mode
    @Environment(\.colorScheme) var colorScheme
    /// The size of the window this view is being displayed in
    @Environment(\.mainWindowSize) var mainWindowSize
    /// This is a bit scuffed, but is used to check if this view is being displayed and should respond to the shake easteregg
    @Environment(\.selectedTabTitle) var selectedTabeTitle
    /// So that each day doesn't need to fetch this, I know this is slow
    @Environment(\.currentUtcDate) var currentUtcDate
    /// These are supposedly expensive to make, so we will avoid making tons of them
    @Environment(\.utcDateFormatter) var utcDateFormatter
    
    /// Pull moodDays from the environment
    @ObservedObject private var moodDays = MoodEventStorage.moodEventStore
    
    /// Sheets for creating/editing entries
    @State private var editSheetShowing = false
    @State private var newSheetShowing = false
    @State private var deleteAlertShowing = false
    @State private var deleteAlertUtcDate: Date? = nil
    
    /// The moodCalenderDay for this date, loaded from the database
    let moodCalendarDay: MoodCalendarDay
    
    /// Falling easteregg things
    @State private var animationAmount = 0.0
    @State private var willFallCount = 0
    @State private var didFall = false;
    
    let timezone = TimeZone(secondsFromGMT: 0) ?? .autoupdatingCurrent
    
    var body: some View {
        
        GeometryReader { geo in
            
            /// The whole date icon
            ZStack {
                
                /// Background for after they fall
                RoundedRectangle(cornerRadius: geo.size.width * 0.2, style: .continuous)
                    .foregroundColor(
                        Color.secondary.opacity(0.25)
                    )
                //
                /// The normal view
                ZStack {
                    
                    BackgroundGradient(moodPoints: moodCalendarDay.moodDay?.moodPoints ?? [])
                        .clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.2, style: .continuous))
                    
                    let components = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: moodCalendarDay.utcDate)
                    //
                    Text(String(components.day ?? 1))
                        .font(.system(size: geo.size.width * 0.75, design: .rounded))
                        .bold()
                        .foregroundColor(colorScheme == .light ? .white.opacity(0.65) : .black.opacity(0.45))
                    
                }
                /// Fun things
                .onTapGesture {
                    doAnimation()
                }
                /// The real easteregg
                .onShake {
                    //
                      /// Hardcoded and kinda bad, but works for now
                    if selectedTabeTitle != "Day List" || didFall {
                        return
                    }
                    //
                    /// Run the animation after a random delay
                    let randomDelay = Double.random(in: 0.0..<0.4)
                    //
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
                .animation(didFall ? .easeIn(duration: 4) : nil, value: didFall)
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
        /// Touch and hold menu
        
        
        
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
    
}

private struct CurrentUtcDateKey: EnvironmentKey {
    static let defaultValue: Date? = Date.now.convertedUtcDate
}

extension EnvironmentValues {
    var currentUtcDate: Date? {
        get { self[CurrentUtcDateKey.self] }
        set { self[CurrentUtcDateKey.self] = newValue }
    }
}

private struct UtcDateFormatterKey: EnvironmentKey {
    static var defaultValue: DateFormatter {
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.timeZone = TimeZone(identifier: "UTC")
        utcDateFormatter.dateStyle = .medium
        utcDateFormatter.timeStyle = .none
        return utcDateFormatter
    }
}

extension EnvironmentValues {
    var utcDateFormatter: DateFormatter {
        get { self[UtcDateFormatterKey.self] }
        set { self[UtcDateFormatterKey.self] = newValue }
    }
}

struct MonthDayView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            MonthDayView(moodCalendarDay: MoodCalendarDay(utcDate: Date.now.convertedUtcDate ?? Date.now, id: UUID()))
                .environment(\.mainWindowSize, geo.size)
        }
    }
}
