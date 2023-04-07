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
    @State private var searchResults = [Date: MoodCalendarDay]()
    
    @State private var sheetItem: MoodCalendarDay? = nil
    
    @FocusState private var searchFocused
    
    var body: some View {
        NavigationView {
            VStack {
                LabeledContent {
                  TextField("Search", text: $searchString)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                }
                .onSubmit {
                    let searchWordList = searchString.split(separator: " ")
                    
                    if searchString.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        withAnimation {
                            searchResults = MoodEventStorage.moodEventStore.findMoodDay(searchDescriptionString: searchWordList.joined(separator: " OR "))
                        }
                    }
                    
                    
                }
                .padding(10)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
                .padding(.bottom)
                .focused($searchFocused)
                .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), radius: 15)
                .submitLabel(.search)
                
           
                
                if searchResults.count == 0 {
                    List{
                        Text("Search something!")
                            .opacity(0.25)
                            .listRowBackground(Rectangle().fill(.ultraThickMaterial))
                    }
                    
                    .onTapGesture {
                        searchFocused = true
                    }
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), radius: 15)
                    .scrollContentBackground(.hidden)
                    
                } else {
                    
                    List {
                        
                        ForEach(searchResults.sorted(by: {return $0.key < $1.key}), id: \.key) { key, value in
                            
                            Button {
                                sheetItem = value
                            } label: {
                                SearchResultView(key: key, value: value)
                            }
                            
                        }
                        .listRowBackground(Rectangle().fill(.ultraThickMaterial))
                        
                    }
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), radius: 15)
                    .scrollContentBackground(.hidden)
                    
                }
                    
            }
            .sheet(item: $sheetItem, content: { value in
                EditEventView(utcDate: value.utcDate, moodPoints: value.moodDay?.moodPoints ?? [], description: value.moodDay?.description ?? "")
            })
            .navigationTitle("Search")
        }
        
    }
    
    struct SearchResultView: View {
        
        var key: Date
        var value: MoodCalendarDay
        
        var body: some View {
            NavigationLink {
                /// This view intentionally left blank :)
            } label: {
                VStack {
                    HStack {
                        
                        Text(key.convertedCurrentTimezoneDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        
                        Spacer()
                        
                    }
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.thinMaterial)
                    Text(value.moodDay?.description ?? "")
                        .font(Font.subheadline)
                        .lineLimit(5)
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
