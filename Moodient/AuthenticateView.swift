//
//  Authenticate.swift
//  Moodient
//
//  Created by Smay on 4/17/23.
//

import SwiftUI
import LocalAuthentication

struct AuthenticateView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("passcodeLocked") var passcodeLocked = false
    
    @Binding var unlocked: Bool
    
    var body: some View {
        
        Button {
                authenticate()
            } label: {
                Text("Auth")
            }
            .opacity(unlocked ? 0 : 1)
            .zIndex(unlocked ? -32767 : 32767)
            .onAppear {
                authenticate()
            }
            .onChange(of: scenePhase) { phase in
                if phase == .background && unlocked && passcodeLocked {
                    unlocked = false
                }
                if phase == .active && !unlocked {
                    authenticate()
                }
            }
        
            

    }
    
    /// Adapted from https://www.hackingwithswift.com/books/ios-swiftui/using-touch-id-and-face-id-with-swiftui
    func authenticate() {
        
        unlocked = false
        
        /// Don't actually propmt if the setting is off
        if !passcodeLocked {
            unlocked = true
            return
        }
        
        let context = LAContext()
        var error: NSError?

        /// Check whether device authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            /// it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                /// authentication has now completed
                if success {
                    unlocked = true
                    /// authenticated successfully
                } else {
                    /// there was a problem
                    print(authenticationError?.localizedDescription as Any)
                }
            }
        } else {
            /// no authentication somehow
            print("No authentication available")
        }
    }
    
}

private struct Unlocked: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var unlocked: Bool {
        get { self[Unlocked.self] }
        set { self[Unlocked.self] = newValue }
    }
}

struct Authenticate_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateView(unlocked: Binding.constant(false))
    }
}
