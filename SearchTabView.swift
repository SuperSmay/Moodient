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
    @State private var searchResults = [SQMoodCalendarDay]()
    
    @State private var sheetItem: SQMoodCalendarDay? = nil
    
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
                    EditEventView(utcDate: value.utcDate)
                })
                
            }
            .navigationTitle("Search")
        }
        
    }
    
    struct SearchResultView: View {
        
        /// These are supposedly expensive to make, so we will avoid making tons of them
        @Environment(\.utcDateFormatter) var utcDateFormatter
        
        var value: SQMoodCalendarDay
        
        var body: some View {
            NavigationLink {
                /// This view intentionally left blank :)
            } label: {
                VStack {
                    HStack {
                        
                        Text(utcDateFormatter.string(from: value.utcDate))
                        
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