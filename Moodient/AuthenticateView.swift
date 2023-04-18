//
//  Authenticate.swift
//  Moodient
//
//  Created by Smay on 4/17/23.
//

import SwiftUI
import LocalAuthentication
import LocalAuthenticationEmbeddedUI

struct AuthenticateView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("biometricLocked") var biometricLocked = false
    @AppStorage("unlockPasscode") var unlockPasscode = ""
    
    @State private var enteredPasscode = ""
    @State private var promptFaceID = true
    
    
    @Binding var unlocked: Bool
    
    var body: some View {
        
        VStack {
            
            Text("Enter your password:")
            
            let biometryType = LAContext().biometricType
            
            if biometricLocked && biometryType != .none {
                Button {
                    authenticate()
                } label: {
                    
                    if biometryType == .faceID {
                        Image(systemName: "faceid")
                    } else {
                        Image(systemName: "touchid")
                    }
                        
                }
                .buttonStyle(.bordered)
                .font(.largeTitle)
                

            }
            
            SecureField("Password", text: $enteredPasscode)
                .onSubmit {
                    authenticate()
                }
                .onChange(of: scenePhase) { phase in
                    
                    if phase == .background && unlocked && unlockPasscode != "" {
                        unlocked = false
                        promptFaceID = true
                    } else if phase == .active && !unlocked && promptFaceID {
                        promptFaceID = false
                        authenticate()
                    }
                    
                }
                .textFieldStyle(.roundedBorder)
                .padding()
        
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .opacity(unlocked ? 0 : 1)
        .zIndex(unlocked ? -32767 : 32767)
        
            

    }
    
    /// Adapted from https://www.hackingwithswift.com/books/ios-swiftui/using-touch-id-and-face-id-with-swiftui
    func authenticate() {

        /// Don't actually prompt if the setting is off
        if unlockPasscode == "" {
            print("Password is empty")
            unlocked = true
            return
        }
        
        unlocked = false
        
        if enteredPasscode == unlockPasscode {
            enteredPasscode = ""
            withAnimation {
                unlocked = true
            }
            return
        } else {
            
        }
        
        if biometricLocked {
            
            let context = LAContext()
            var error: NSError?
            
            /// Check whether device authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                /// it's possible, so go ahead and use it
                let reason = "We need to unlock your data."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    /// authentication has now completed
                    if success {
                        withAnimation {
                            unlocked = true
                        }
                        
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
