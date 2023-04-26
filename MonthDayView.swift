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
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest var moodDays: FetchedResults<MoodDay>
    
    @Binding var deleteUtcDate: Date?
    @Binding var editUtcDate: Date?
    @Binding var deleteAlertShowing: Bool

    init(utcDate: Date, editUtcDate: Binding<Date?>, deleteUtcDate: Binding<Date?>, deleteAlertShowing: Binding<Bool>) {
        self.utcDate = utcDate
        self._deleteUtcDate = deleteUtcDate
        self._editUtcDate = editUtcDate
        self._deleteAlertShowing = deleteAlertShowing
        let predicate = NSPredicate(format: "utcDate == %@", utcDate as CVarArg)
        self._moodDays = FetchRequest(sortDescriptors: [], predicate: predicate) 
    }
    
    /// The utcDate for this view
    let utcDate: Date
    
    /// Falling easteregg things
    @State private var animationAmount = 0.0
    @State private var willFallCount = 0
    @State private var didFall = false;
    
    let timezone = TimeZone.gmt
    
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
                    
                    BackgroundGradient(moodPoints: moodDays.first?.moodPoints ?? [])
                        .clipShape(RoundedRectangle(cornerRadius: geo.size.width * 0.2, style: .continuous))
                    
                    let components = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: utcDate)
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
        .contextMenu {
            
            Section {
                Button {
                    
                } label: {
                    Label(utcDateFormatter.string(from: utcDate), systemImage: "calendar")
                }
                    .disabled(true)
            }
            
            Section {
                /// If the date should be able to be edited, then show the edit button
                if (currentUtcDate != nil && utcDate <= currentUtcDate!) {
                    Button(action: {
                        
                        print(utcDate)
                        
                        editUtcDate = utcDate
                        
                    }, label: {
                        Label("Edit", systemImage: "pencil")
                    })
                    
                    if (moodDays.first != nil) {
                        Button(role: .destructive) {
                            deleteUtcDate = utcDate
                            deleteAlertShowing.toggle()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    /// Otherwise, show a disabled button (Text doesn't work so this was the best option) that has a fun message
                } else {
                    
                    let daysAway = (Calendar.autoupdatingCurrent.dateComponents([.day], from: currentUtcDate ?? Date.now, to: utcDate).day ?? -1)
                    let daysAwayText = daysAway == 1 ? "tomorrow!" : "\(daysAway) days from now"
                    Button("That's \(daysAwayText)") {}
                        .disabled(true)
                }
            }
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
        utcDateFormatter.timeZone = TimeZone.gmt
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
            MonthDayView(utcDate: Date.now.convertedUtcDate!, editUtcDate: Binding.constant(nil), deleteUtcDate: Binding.constant(nil), deleteAlertShowing: Binding.constant(true))
                .environment(\.mainWindowSize, geo.size)
        }
    }
}
