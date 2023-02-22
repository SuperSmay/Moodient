//
//  MoodTimelineControlView.swift
//  Moodient
//
//  Created by Smay on 2/18/23.
//

import SwiftUI

struct MoodTimelineControlView: View {
    
    @Environment(\.mainWindowSize) var mainWindowSize
    
    @State private var dragOffset = CGSize.zero
    
    @Binding var moodPoints: [MoodPoint]
    
    var body: some View {
        
        
        VStack {
            
            HStack {
                Spacer()
                
                Button {
                    moodPoints.append(MoodPoint(utcTime: Date.now.convertedUtcDate ?? Date.now, moodValue: 0))
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            HStack {
                ForEach(0..<24) { i in
                    
                        Color.clear
                            .overlay {
                                ZStack {
                                    
                                    ForEach(getPointsWithHour(i), id: \.self.wrappedValue) { point in
                                        DragableMood(moodPoint: point)
                                            .frame(width: 60, height: 50)
                                    }
                                }
                            }
                }
            }
        }
        
    }
    
    func getPointsWithHour(_ hour: Int) -> [Binding<MoodPoint>] {
        
        var temp = [Binding<MoodPoint>]()
        
        for point in $moodPoints {
            
            if Calendar.autoupdatingCurrent.date(point.utcTime.wrappedValue, matchesComponents: DateComponents(hour: hour)) {
                
                temp.append(point)
            }
        }
        
        return temp
        
    }
        
    
    
    struct DragableMood: View {
        
        //@State private var hourValue = 0
        
        @Binding var moodPoint: MoodPoint
        
        var body: some View {
            
                
                HStack(spacing: 0) {
                    
                    Button {
                        moodPoint.utcTime = change(utcTime: $moodPoint.utcTime.wrappedValue, by: -1)
                    } label: {
                        Image(systemName: "arrowtriangle.backward.fill")
                            
                    }

                    
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
                    
                    Button {
                        moodPoint.utcTime = change(utcTime: $moodPoint.utcTime.wrappedValue, by: 1)
                    } label: {
                        Image(systemName: "arrowtriangle.forward.fill")
                            
                    }
                    
                    
                
                
                }
                .background {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        //.frame(width: 200)
                        .foregroundStyle(.ultraThinMaterial)
                
               
            }
        
        }
                      
        func change(utcTime date: Date, by offset: Int) -> Date {
            
            guard let newDate = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: offset, to: date) else {
                return date
            }
            
            return newDate
        
        }
            
    }
    
    
    
}

struct MoodTimelineControlView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTimelineControlView(moodPoints: Binding.constant([MoodPoint(utcTime: Date.now.convertedUtcDate ?? Date.now, moodValue: 0)]))
        /// Make it a reasonable size
            .frame(height: 70)
    }
}
