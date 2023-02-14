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
    
    
    /// Drag stuff
    @State private var dragOffset = CGSize.zero
    @State private var changeRatio = 0.0
    @State private var changeWidth = 0.0
    
    /// Transitions
    @State private var isTransitioningUp = false
    @State private var monthID = UUID() /// This is to store the current ID of the month being shown, so that we can change it later and use transitions
    
    /// Button hold stuff
    @State var timeRemaining = 0.5
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var userIsPressing = false //detecting whether user is long pressing the screen
    @State private var buttonWasHeld = false

    @Environment(\.colorScheme) var colorScheme
    /// The size of the window this view is being displayed in
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        
        NavigationView {
            VStack()
            {
                let monthIndex = Calendar.current.dateComponents([.month], from: month).month
                
                Button() {
                    
                } label: {
                    let newDate = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? Date.now
                    
                    let newIndex = Calendar.current.dateComponents([.month], from: newDate).month
                    
                    
                    Label(Calendar.current.monthSymbols[(newIndex ?? 1) - 1] + " " + String(Calendar.current.component(.year, from: month)), systemImage: "chevron.down")
                        .padding()
                        .background(Color.secondary.opacity(0.5))
                    //.foregroundColor(.primary)
                        .background {
                            GeometryReader { geo in
                                let frameWidth = changeRatio > 0 ? geo.frame(in: .global).width * changeRatio : 0
                                Color.primary
                                    .frame(width: frameWidth, alignment: .leading)
                            }
                        }
                        .animation(.easeInOut, value: month)
                        .animation(.easeInOut, value: changeRatio)
                        
                                            
                
                        
                }
                .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                .onReceive(self.timer) { _ in
                    if self.userIsPressing {
                        if self.timeRemaining > 0 {
                            self.timeRemaining -= 0.5
                        }
                        //resetting the timer every 0.5 secdonds and executing code whenever //timer reaches 0
                        
                        if self.timeRemaining == 0 {
                            withAnimation(.spring(dampingFraction: 0.7, blendDuration: 0.5)) {
                                if buttonWasHeld {
                                    backOneMonth()
                                } else {
                                    buttonWasHeld = true
                                }
                                
                            }
                            self.timeRemaining = 0.5
                        }
                    }
                }
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { value in
                    
                    
                    if !buttonWasHeld && !value {

                        withAnimation(.spring(dampingFraction: 0.7, blendDuration: 0.5)) {
                            backOneMonth()
                        }
                        
                    }
                    
                    self.userIsPressing = value
                    
                    if !userIsPressing {
                        buttonWasHeld = false
                    }
                   
                        
                    
                }, perform: {
                    
                } )
                
                Spacer()
                
                
                MonthView(dayInMonth: month)
                        
                        
                        .padding()
                        .navigationTitle("\(Calendar.current.monthSymbols[(monthIndex ?? 1) - 1]) \(String(Calendar.current.component(.year, from: month)))")
                            
                        
                        .offset(y: dragOffset.height)
                        
                        
                        .gesture(
                            DragGesture()
                                .onChanged({ gesture in
                                    dragOffset = gesture.translation
                                    changeRatio = gesture.translation.height/mainWindowSize.height * 2 * 2
                                })
                                .onEnded({ gesture in
                                    withAnimation(.spring(dampingFraction: 0.7, blendDuration: 0.5)) {
                                        if changeRatio >= 1 {
                                                backOneMonth()
                                            }
                                        
                                        if changeRatio <= -1 {
                                                forwardOneMonth()
                                            }
                                            
                                        dragOffset = CGSize.zero
                                        changeRatio = 0
                                    }
                                    
                                    
                                        
                                    
                                }))
                        
                    
                
                .id(monthID) /// https://sakunlabs.com/blog/swiftui-identity-transitions/ THATS IT
                .transition(.asymmetric(insertion: .offset(y: isTransitioningUp ? mainWindowSize.height : mainWindowSize.height * -1), removal: .opacity.combined(with: .scale)))
                
                //Text("\(changeRatio)")
                Spacer()
                
                Button() {
                    withAnimation(.spring(dampingFraction: 0.7, blendDuration: 0.5)) {
                        forwardOneMonth()
                    }
                } label: {
                    let newDate = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? Date.now
                    
                    let newIndex = Calendar.current.dateComponents([.month], from: newDate).month
                    
                    
                    Label(Calendar.current.monthSymbols[(newIndex ?? 1) - 1] + " " + String(Calendar.current.component(.year, from: month)), systemImage: "chevron.up")
                                .padding()
                                .background(Color.secondary.opacity(0.5))
                                //.foregroundColor(.primary)
                                .background {
                                    GeometryReader { geo in
                                        let frameWidth = changeRatio < 0 ? geo.frame(in: .global).width * changeRatio * -1: 0
                                        Color.primary
                                            .frame(width: frameWidth, alignment: .leading)
                                    }
                                }
                                .animation(.easeInOut, value: month)
                                .animation(.easeInOut, value: changeRatio)
                    
                        
                }
                .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                
                
        }
        }
    }

    
    func backOneMonth() {
        isTransitioningUp = false
        monthID = UUID()
        let newDate = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? Date.now
        month = newDate
    }
    
    func forwardOneMonth() {
        isTransitioningUp = true
        monthID = UUID()
        let newDate = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? Date.now
        month = newDate
    }
    
    
    /// Callback to delete rows from the database when rows are deleted from the UI
    func removeRows(at offsets: IndexSet) {
        let id = offsets.map { self.moodDays[$0].id }.first

        if let id = id {
            let delete = MoodEventStorage.moodEventStore.delete(id: id)
            if delete {
                reload()
            }
        }
    }
    
    func reload() {
        moodDays = MoodEventStorage.moodEventStore.getAllMoodDays()
    }
    
}

struct FullEventView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            FullEventView()
                .environment(\.mainWindowSize, geo.size)
        }
    }
}
