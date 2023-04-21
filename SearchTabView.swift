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
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var moodDays: FetchedResults<MoodDay>
    @State private var searchString = ""
    var query: Binding<String> {
        Binding {
            searchString
        } set: { newValue in
            searchString = newValue
            moodDays.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS %@", newValue)
        }
    }

    
    @State private var sheetItem: MoodDay? = nil
    
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
                    .focused($searchFocused)
                    .submitLabel(.search)
                }
                
                
                
                Section {
                    
                    ForEach(moodDays, id: \.utcDate) { moodDay in
                        
                        Button {
                            sheetItem = moodDay
                        } label: {
                            SearchResultView(value: moodDay)
                        }
                        .foregroundColor(.primary)
                        
                        
                    }
                    
                    
                }
                .sheet(item: $sheetItem, content: { value in
                    EditEventView(utcDate: value.utcDate ?? Date.now)
                })
                
            }
            .navigationTitle("Search")
        }
        
    }
    
    struct SearchResultView: View {
        
        /// These are supposedly expensive to make, so we will avoid making tons of them
        @Environment(\.utcDateFormatter) var utcDateFormatter
        
        var value: MoodDay
        
        var body: some View {
            NavigationLink {
                /// This view intentionally left blank :)
            } label: {
                VStack {
                    HStack {
                        
                        Text(utcDateFormatter.string(from: value.utcDate ?? Date.now))
                        
                        Spacer()
                        
                    }
                    
                    let moodPointsArray = value.moodPoints
                    
                    BackgroundGradient(moodPoints: moodPointsArray ?? [])
                        .opacity(0.2)
                        .frame(height: 2)
                        .foregroundStyle(.thinMaterial)
                    HStack {
                        Text(value.dayDescription ?? "")
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
