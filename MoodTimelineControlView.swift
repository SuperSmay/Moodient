//
//  MoodTimelineControlView.swift
//  Moodient
//
//  Created by Smay on 2/18/23.
//

import SwiftUI

struct MoodTimelineControlView: View {
    
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.managedObjectContext) var moc

    @State private var dragOffset = CGSize.zero
    @State private var draggedPoint: UUID? = nil
    
    @State private var deleteOnRelease = false
    
    @State private var previousHourOffset = 0
    
    @Binding var moodPoints: [MoodPoint]
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                
                Button {
                    
//                    let newMoodPoint = MoodPoint(context: moc)
//                    newMoodPoint.utcTime = Date.now.convertedUtcTime ?? Date.now
//                    newMoodPoint.moodValue = 0
//
//                    moodPoints.append(newMoodPoint)
                    
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(moodPoints.count > 4)
            }
            
            VStack {
                
                HStack(spacing: 0) {
                    ForEach(0..<24) { i in
                        
                        Color.clear
                            .overlay {
                                if i % 3 == 0 {
                                    
                                    let hourInt = Date.is24HoursFormat ? i : i % 12
                                    
                                    Text(String(hourInt == 0 && !Date.is24HoursFormat ? 12 : hourInt))
                                        .fontDesign(.rounded)
                                        .bold()
                                        .foregroundColor(.secondary.opacity(0.35))
                                        .contentShape(Rectangle())
                                        .frame(width: 100)
                                       

                                }
                                
                            }
                        
                        
                    }
                }
                
                ZStack {
                    
                    HStack(spacing: 0) {
                        ForEach(0..<24) { i in
                            
                            Color.clear
                                .background {
                                    Rectangle()
                                        .foregroundColor(.secondary.opacity(0.15))
                                        .frame(width: 3)
                                }
                            
                            
                        }
                    }
                    
                    HStack(spacing: 0) {
                        
                        
                        
                        
//                        ForEach(0..<24) { i in
//                            
//                            GeometryReader { geo in
//                                Color.clear
//                                    .overlay {
//                                        ZStack {
//                                            /// Filter the whole list into just the points that match the current hour
//                                            
//                                            let timezone = TimeZone.gmt
//                                            
//                                            ForEach($moodPoints.filter( {
//                                                
//                                                Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: $0.utcTime.wrappedValue).hour == i
//
//                                            }), id: \.self.wrappedValue) { $point in
//                                                DragableMood(moodPoint: $point)
//                                                    /// Force this size. Kinda bad but will fix eventually
//                                                    .frame(width: 60, height: 50)
//                                                    /// Delete gesture things
//                                                    .opacity(draggedPoint == point.uuid && deleteOnRelease ? 0.2 : 1)
//                                                    .overlay {
//                                                        Image(systemName: "trash")
//                                                            .foregroundColor(.red)
//                                                            .scaleEffect(draggedPoint == point.uuid && deleteOnRelease ? 1 : 0)
//                                                            .animation(deleteOnRelease ? .spring(response: 0.25, dampingFraction: 0.2, blendDuration: 0.05) : nil, value: deleteOnRelease)
//                                                            .offset(y:-50)
//                                                    }
//                                                
//                                                    .offset(draggedPoint == point.uuid ? dragOffset : CGSize.zero)
//                                                    
//                                                    .gesture(
//                                                        DragGesture()
//                                                            .onChanged({ gesture in
//                                                                
//                                                                let xOffset = gesture.translation.width
//                                                                var yOffset = 0.0
//                                                                
//                                                                draggedPoint = point.uuid
//                                                                
//                                                                /// Delete things
//                                                                
//                                                                if (abs(gesture.translation.height) > geo.frame(in: .global).height) {
//                                                                    yOffset = gesture.translation.height
//                                                                }
//                                                                
//                                                                let deleteRatio = abs(yOffset/(geo.frame(in: .global).height * 2))
//                                                                
//                                                                /// When delete is primed
//                                                                if !deleteOnRelease && deleteRatio >= 1 {
//                                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                                                    deleteOnRelease = true
//                                                                } else if deleteRatio >= 1 {
//                                                                    deleteOnRelease = true
//                                                                } else {
//                                                                    deleteOnRelease = false
//                                                                }
//                                                                
//                                                                /// Slider haptics
//                                                                let hourChange = gesture.translation.width/geo.frame(in: .global).width
//                                                                
//                                                                if Int(hourChange) != previousHourOffset && deleteRatio == 0 {
//                                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                                                }
//                                                                
//                                                                previousHourOffset = Int(hourChange)
//                                                                    
//                                                                dragOffset = CGSize(width: xOffset, height: yOffset)
//                                                                
//                                                                
//                                                            })
//                                                            .onEnded({ gesture in
//                                                                
//                                                                let hourChange = gesture.translation.width/geo.frame(in: .global).width
//                                                                
//                                                                draggedPoint = nil
//                                                                
//                                                                dragOffset = CGSize.zero
//                                                                
//                                                                if deleteOnRelease {
//                                                                    moodPoints.removeAll(where: {$0 == point})
//                                                                } else {
//                                                                    
//                                                                    point.utcTime = change(utcTime: point.utcTime, by: Int(hourChange))
//                                                                    
//                                                                    /// Sort the moodPoints list by hour
//                                                                    moodPoints = moodPoints.sorted(by: {
//                                                                        let components0 = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: $0.utcTime)
//                                                                        let components1 = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: $1.utcTime)
//                                                                        return components0.hour ?? 0 < components1.hour ?? 0
//                                                                        
//                                                                            })
//                                                                    
//                                                                }
//                                                                
//                                                                deleteOnRelease = false
//                                                                
//                                                            }))
//                                                
//                                            }
//                                        }
//                                    }
//                                
//                            }
//                            
//                        }
                        
                        
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    
        
    
    
    struct DragableMood: View {
        
        @Binding var moodPoint: SQMoodPoint
        
        var body: some View {
            
                
                HStack(spacing: 0) {
                    
                    Image(systemName: "arrowtriangle.backward.fill")
                    
                    Menu {
                        ForEach(0..<5) { i in
                            Button {
                                moodPoint.moodValue = i
                            } label: {
                                Text(MoodOptions.options.moodLabels[i])
                            }
                        }
                    } label: {
                        Circle()
                            .foregroundColor(MoodOptions.options.moodColors[$moodPoint.moodValue.wrappedValue])
                    }
                    
                    Image(systemName: "arrowtriangle.forward.fill")
                
                }
                .background {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        //.frame(width: 200)
                        .foregroundStyle(.ultraThinMaterial)
                
               
            }
        
        }
                      
        
            
    }
    
    
    
}

struct MoodTimelineControlView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTimelineControlView(moodPoints: Binding.constant([]))
        /// Make it a reasonable size
            .frame(height: 70)
    }
}

func change(utcTime date: Date, by offset: Int) -> Date {
    
    let timezone = TimeZone.gmt
    
    guard let oldHour = Calendar.autoupdatingCurrent.dateComponents(in: timezone, from: date).hour else {
        return date
    }
    
    var adjustedOffset = offset
    
    if oldHour + offset > 23 {
        adjustedOffset = 23 - oldHour
    } else if oldHour + offset < 0 {
        adjustedOffset = 0 - oldHour
    }
    
    guard let newDate = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: adjustedOffset, to: date) else {
        return date
    }
             
    return newDate

}
