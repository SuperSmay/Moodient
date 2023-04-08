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
    
    @State private var debugCount = 0
    @State private var debugToastShowing = false
    
    @State private var animationAmount = 0.0
    
    let DISCORD_URL = "https:/discordapp.com/users/243759220057571328"
    let GITHUB_URL = "https://github.com/SuperSmay/Moodient"
    let MASTODON_URL = "https://mstdn.social/@smay"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                /// App icon
                /// https://stackoverflow.com/a/62064533
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .rotationEffect(Angle.degrees(animationAmount))
                /// Fun things
                    .onTapGesture {
                        doAnimation()
                    }
                    .animation(
                        .spring(dampingFraction: 0.2),
                        value: animationAmount
                    )
                
                VStack {
                    
                    /// Copied from the below stackoverflow
                    let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Error"
                   
                    Text(appName)
                        .font(.title)
                        .bold()
                    
                    /// https://stackoverflow.com/a/26011822
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Error"
                    
                    Text("Version \(appVersion)" + (MoodOptions.options.debug ? " Developer Mode" : ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            
                            if !MoodOptions.options.debug {
                                debugCount += 1
                            }
                            
                            if debugCount == 10 {
                                MoodOptions.options.debug = true
                            }
                            
                            if debugCount > 3 || MoodOptions.options.debug {
                                debugToastShowing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    debugToastShowing = false
                                }
                            }
                            
                            
                            
                            
                            
                        }
                }
                
                
                Text("By Smay")
                
                HStack {

                    Button {
                        
                        urlToOpen = URL(string: MASTODON_URL)
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
                        
                        urlToOpen = URL(string: DISCORD_URL)
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
                        
                        urlToOpen = URL(string: GITHUB_URL)
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
                
                Text("Made with love in Wisconsin 🧀\nThank you Tori for the name, and Raya for debugging")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
            }
            .navigationBarTitleDisplayMode(.inline)
        }

        .overlay(alignment: .bottom) {
            Text(MoodOptions.options.debug ? "Developer mode has been turned on" : "You are \(10 - debugCount) steps away from being a developer.")
                .foregroundStyle(.ultraThickMaterial)
                .padding()
                .background(.secondary)
                
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
                .opacity(debugToastShowing ? 1 : 0)
                .animation(debugToastShowing ? nil : .easeInOut, value: debugToastShowing)
        }
    }
    
    /// Adjusts the animation values and does the haptics
    func doAnimation() {
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        if animationAmount == 0 {
            animationAmount += Double.random(in: -45..<45)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animationAmount = 0
            }
        }
    }
    
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
