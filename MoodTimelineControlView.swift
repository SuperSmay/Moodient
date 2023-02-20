//
//  MoodTimelineControlView.swift
//  Moodient
//
//  Created by Smay on 2/18/23.
//

import SwiftUI

struct MoodTimelineControlView: View {
    
    @State private var dragOffset = CGSize.zero
    
    @Binding var moodPoints: [MoodPoint]
    
    var body: some View {
        
        GeometryReader { geo in
            VStack(alignment: .leading) {
                
                Button {
                    moodPoints.append(MoodPoint(utcTime: Date.now, moodValue: 0))
                } label: {
                    Image(systemName: "plus")
                }
                
                ZStack {
                    
                    Rectangle()
                        .foregroundColor(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                    
                    ForEach($moodPoints, id: \.self) { point in
                        
                        
                        let hours = Calendar.autoupdatingCurrent.dateComponents([.hour], from: point.utcTime.wrappedValue).hour ?? 0
                        
                        /// Get the ratio of movement from the center
                        let ratio = (Double(hours)/24.0) - 0.5
                        
                        let offset = geo.frame(in: .global).width * ratio
                        
                        DragableMood(moodPoint: point).offset(x:offset)
                    }
                   
                    
                    
                }
            }
        }
        .frame(width: 300, height: 100)
    }
    
    struct DragableMood: View {
        
        @Binding var moodPoint: MoodPoint
        
        var body: some View {
            
                
                HStack {
                    
                    Button {
                        moodPoint.utcTime = change(utcTime: $moodPoint.utcTime.wrappedValue, by: -1)
                    } label: {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .padding()
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
                            .padding()
                    }
                    
                    
                
                
                }
                .background {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        //.frame(width: 200)
                        .foregroundStyle(.ultraThinMaterial)
                
               
            }
        
        }
                      
                      func change(utcTime date: Date, by offset: Int) -> Date {
                          var newUtcTime = Calendar.current.date(bySetting: .minute, value: 0, of: date)
                          newUtcTime = Calendar.current.date(byAdding: .hour, value: offset, to: newUtcTime ?? Date.now)
                         return newUtcTime ?? Date.now
                      }
    }
    
    
    
}

struct MoodTimelineControlView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTimelineControlView(moodPoints: Binding.constant([MoodPoint(utcTime: Date.now, moodValue: 0)]))
    }
}
