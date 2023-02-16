//
//  LazyCompleteDayList.swift
//  Moodient
//
//  Created by Smay on 2/8/23.
//

import SwiftUI
import NaiveDate

struct FullEventView: View {
    
    @State var moodDays = MoodEventStorage.moodEventStore.getAllMoodDays()
    @State private var editSheetShowing = false
    @State private var editSheetMoodDay: MoodCalendarDay? = nil
    @State private var newSheetShowing = false
    
    @State private var month = Date.now
    
    let springTransition = Animation.spring(dampingFraction: 0.7, blendDuration: 0.5)
    
    /// Drag stuff
    @State private var dragOffset = CGSize.zero
    @State private var changeRatio = 0.0
    
    /// Transitions
    @State private var isTransitioningUp = false  /// Keep track of which way the transition will happen
    @State private var monthID = UUID()  /// This is to store the current ID of the month being shown, so that we can change it later and use transitions
    
    /// Button hold stuff
    /// https://stackoverflow.com/questions/62239854/how-to-make-a-longpressgesture-that-runs-repeatedly-while-the-button-is-still-be
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State var timeRemaining = 0.0
    @State private var buttonRepeatTime = 0.5
    @State private var buttonRepeatMonthCount = 1
    
    @State var userIsPressing = false //detecting whether user is long pressing the screen
    @State private var buttonWasHeld = false
    @State private var buttonDirectionHeld = MonthDirection.backward

    @Environment(\.colorScheme) var colorScheme
    /// The size of the window this view is being displayed in
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                let monthIndex = Calendar.autoupdatingCurrent.dateComponents([.month], from: month).month
                
                Button() { } label: {
                    
                    MonthChangeButton(month: month, direction: .backward, fillPercent: changeRatio)
                    
                }
                .padding(.vertical)
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { value in
                    
                    /// Reset the remaining until trigger when the drag starts/ends
                    self.timeRemaining = buttonRepeatTime
                    
                    buttonDirectionHeld = .backward
                    
                    /// Only trigger on release if the button was not held down
                    if !buttonWasHeld && !value {
                        
                        withAnimation(springTransition) {
                            changeMonth(by: -1)
                        }
   
                    }
                    
                    self.userIsPressing = value
                    
                    /// If the gesture was released, then the button is no longer being held
                    if !userIsPressing {
                        buttonRepeatTime = 0.5
                        buttonRepeatMonthCount = 1
                        buttonWasHeld = false
                    }
                    
                }, perform: { })
                
                Spacer()
                                
                MonthView(dayInMonth: month)
                    .id(monthID) /// https://sakunlabs.com/blog/swiftui-identity-transitions/ THATS IT
                    .padding()
                    .navigationTitle("\(Calendar.autoupdatingCurrent.monthSymbols[(monthIndex ?? 1) - 1]) \(String(Calendar.autoupdatingCurrent.component(.year, from: month)))")
                    .offset(y: dragOffset.height)
                    .zIndex(-1)
                    /// These two make the whole area around the month swipeable
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    /// The drag gesture
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                dragOffset = gesture.translation
                                changeRatio = gesture.translation.height/mainWindowSize.height * 2 * 2
                            })
                            .onEnded({ gesture in
                                withAnimation(springTransition) {
                                    if changeRatio >= 1 {
                                        changeMonth(by: -1)
                                    }
                                    
                                    if changeRatio <= -1 {
                                        changeMonth(by: 1)
                                    }
                                    
                                    dragOffset = CGSize.zero
                                    changeRatio = 0
                                }
      
                            }))
                    .transition(.asymmetric(insertion: .offset(y: isTransitioningUp ? mainWindowSize.height : mainWindowSize.height * -1), removal: .opacity.combined(with: .scale)))

                Spacer()
                
                let currentMonthAndYear = Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: Date.now)
                let displayMonthAndYear = Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: month)
                if (currentMonthAndYear != displayMonthAndYear) {
                    Button() {
                        withAnimation(springTransition) {
                            month = .now
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            /// UUID is not changed, so that the animation is different to indicate that something different changed
                        }
                    } label: {
                        Text("Jump to Today")
                            .padding()
                            .foregroundColor(.white)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                    }
                    

                }
                
                Button() { } label: {
                    
                    MonthChangeButton(month: month, direction: .forward, fillPercent: changeRatio * -1)
    
                }
                .padding(.vertical)
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { value in
                    
                    buttonDirectionHeld = .forward
                    
                    /// Reset the remaining until trigger when the drag starts/ends
                    self.timeRemaining = buttonRepeatTime
                    
                    /// Only trigger on release if the button was not held down
                    if !buttonWasHeld && !value {
                        
                        withAnimation(springTransition) {
                            changeMonth(by: 1)
                        }
   
                    }
                    
                    self.userIsPressing = value
                    
                    
                    /// If the gesture was released, then the button is no longer being held
                    if !userIsPressing {
                        buttonRepeatTime = 0.5
                        buttonRepeatMonthCount = 1
                        buttonWasHeld = false
                    }
                    
                }, perform: { })
     
            }
            /// Make holding button work
            .onReceive(self.timer) { _ in
                /// If the user is pressing the button when the timer event is received
                if self.userIsPressing {
                    /// If there is time left on the timer, then remove 0.1 seconds
                    if round(self.timeRemaining * 10)/10.0 > 0 {
                        self.timeRemaining -= 0.1
                    }
                    
                    /// If the timer reached 0, do a thing
                    if round(self.timeRemaining * 10)/10.0 <= 0 {
                        
                        if round(buttonRepeatTime * 10)/10 > 0.1 {
                            buttonRepeatTime -= 0.1
                        } else {
                            buttonRepeatMonthCount += 1
                        }
                        
                        var monthChange = 1
                        monthChange += buttonRepeatMonthCount/50
                        monthChange *= buttonDirectionHeld == .forward ? 1 : -1
                        
                        withAnimation(springTransition) {
                            changeMonth(by: monthChange)
                        }
                        
                        buttonWasHeld = true
                        
                        self.timeRemaining = buttonRepeatTime
                        
                    }
                }
            }
        }
    }
    
    func changeMonth(by change: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isTransitioningUp = change > 0
        monthID = UUID()
        let newDate = Calendar.autoupdatingCurrent.date(byAdding: .month, value: change, to: month) ?? Date.now
        month = newDate
    }
    
}

struct MonthChangeButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let month: Date
    let direction: MonthDirection
    let fillPercent: Double
    
    var body: some View {
        
        let newDate = Calendar.autoupdatingCurrent.date(byAdding: .month, value: direction == .forward ? 1 : -1, to: month) ?? Date.now
        let newIndex = Calendar.autoupdatingCurrent.dateComponents([.month], from: newDate).month
        let monthName = Calendar.autoupdatingCurrent.monthSymbols[(newIndex ?? 1) - 1]
        let year = Calendar.autoupdatingCurrent.component(.year, from: newDate)
        
        Label("\(monthName) \(year.formatted(.number.grouping(.never)))", systemImage: "chevron.\(direction == .forward ? "up" : "down")")
            .padding()
            .foregroundColor(.primary)
            
            /// Progress bar things
            .background {
                /// In .background to avoid resizing view
                GeometryReader { geo in
                    /// Calculate the width of the "progress bar"
                    
                    
                    let frameWidth = fillPercent > 0 ? geo.frame(in: .global).width * fillPercent : 0
                    /// The "progress bar" itself
                    Color.white.opacity(0.75)
                        .frame(width: frameWidth, alignment: .leading)
                    
                    
                }
            }
            .background(Color.secondary.opacity(0.5))
            /// Don't apply an animation to the progress thing
            .animation(nil, value: fillPercent)

            .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
            /// Fancy stretch
            
            .scaleEffect(x: fillPercent > 0 ? 1.0 + fillPercent/30 : 1, anchor: .leading)
            .shadow(color: colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.1), radius: fillPercent > 0 ? 10 : 0)
            /// Animations
            .animation(.easeInOut, value: month)
            .animation(.easeInOut, value: fillPercent)
    }
    
}

enum MonthDirection {
    case forward
    case backward
}

struct FullEventView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            FullEventView()
                .environment(\.mainWindowSize, geo.size)
        }
    }
}
