//
//  SearchTabView.swift
//  Moodient
//
//  Created by Smay on 4/6/23.
//

import SwiftUI

struct SearchTabView: View {
    
    /// Env variables
    @Environment(\.colorScheme) var colorScheme
    
    @State private var searchString = ""
    @State private var searchResults = [MoodCalendarDay]()
    
    @State private var sheetItem: MoodCalendarDay? = nil
    
    @FocusState private var searchFocused
    
    var body: some View {
        NavigationView {
            List {
                
                Section {
                    
                    LabeledContent {
                        TextField("Search", text: $searchString)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                    }
                    .onSubmit {
                        
                        let searchWordList = searchString.split(separator: " ")
                        
                        print("Submit \(searchWordList)")
                        
                        
                        withAnimation {
                            
                            if searchString.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                
                                print("Running search")
                                
                                searchResults = Array(MoodEventStorage.moodEventStore.findMoodDay(searchDescriptionString: searchWordList.joined(separator: " OR ")).values)
                                
                                print(searchResults)
                                
                            } else {
                                searchResults = []
                            }
                        }
                    }
                    
                    .focused($searchFocused)
                    .submitLabel(.search)
                }
                
                
                
                Section {
                    
                    ForEach(searchResults, id: \.utcDate) { moodCalendarDay in
                        
                        Button {
                            sheetItem = moodCalendarDay
                        } label: {
                            SearchResultView(value: moodCalendarDay)
                        }
                        .foregroundColor(.primary)
                        
                        
                    }
                    
                    
                }
                .sheet(item: $sheetItem, content: { value in
                    EditEventView(utcDate: value.utcDate, moodPoints: value.moodDay?.moodPoints ?? [], description: value.moodDay?.description ?? "")
                })
                
            }
            .navigationTitle("Search")
        }
        
    }
    
    struct SearchResultView: View {
        
        var value: MoodCalendarDay
        
        var body: some View {
            NavigationLink {
                /// This view intentionally left blank :)
            } label: {
                VStack {
                    HStack {
                        
                        Text(value.utcDate.convertedCurrentTimezoneDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        
                        Spacer()
                        
                    }
                    BackgroundGradient(moodPoints: value.moodDay?.moodPoints ?? [])
                        .opacity(0.2)
                        .frame(height: 2)
                        .foregroundStyle(.thinMaterial)
                    HStack {
                        Text(value.moodDay?.description ?? "")
                            .font(Font.subheadline)
                        .lineLimit(5)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct SearchTabView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTabView()
    }
}
