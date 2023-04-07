//
//  AboutView.swift
//  Moodient
//
//  Created by Smay on 4/7/23.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.openURL) private var openURL
    
    @State private var urlToOpen: URL? = nil
    @State private var openAlertShowing = false
    
    var body: some View {
        VStack(spacing: 10) {
            /// App icon
            /// https://stackoverflow.com/a/62064533
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            VStack {
                
                /// Copied from the below stackoverflow
                let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Error"
               
                Text(appName)
                    .font(.title)
                    .bold()
                
                /// https://stackoverflow.com/a/26011822
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Error"
                
                Text("Version \(appVersion)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            
            Text("By Smay")
            
            HStack {

                Button {
                    
                    urlToOpen = URL(string: "https://mstdn.social/@smay")
                    openAlertShowing = true
                    
                } label: {
                    Image("mastodon.fill")
                        .renderingMode(.original)
                        .font(.system(size: 30))
                        .padding()
                        .background(.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                }
                
                
                Button {
                    
                    urlToOpen = URL(string: "https://discordapp.com/users/243759220057571328")
                    openAlertShowing = true
                    
                } label: {
                    Image("discord.fill")
                        .renderingMode(.original)
                        .font(.system(size: 30))
                        .padding()
                        .background(.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                
                Button {
                    
                    urlToOpen = URL(string: "https://github.com/SuperSmay/Moodient")
                    openAlertShowing = true
                    
                } label: {
                    Image("github.fill")
                        .renderingMode(.original)
                        .font(.system(size: 30))
                        .padding()
                        .background(.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                
                
            }
            .alert("Open URL?", isPresented: $openAlertShowing) {
                
                
                Button(role: .cancel) {
                    
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    if (urlToOpen != nil) {
                        openURL(urlToOpen!)
                    }
                } label: {
                    Text("Open")
                }
                .keyboardShortcut(.defaultAction)
            }
            
            
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
