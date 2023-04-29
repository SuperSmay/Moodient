//
//  SettingsView.swift
//  Moodient
//
//  Created by Smay on 2/5/23.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    
    @AppStorage("developerMode") var developerMode = false
    @AppStorage("passcodeLocked") var passcodeLocked = false
    @AppStorage("biometricLocked") var biometricLocked = false
    @AppStorage("unlockPasscode") var unlockPasscode = ""
    @AppStorage("hourOffset") var hourOffset = 0
    
    @State private var enteredUnlockPasscode = ""
    @State private var confirmUnlockPasscode = ""
    @State private var passwordAlertPresented = false
    
    var passwordsMatch: Bool {
        enteredUnlockPasscode == confirmUnlockPasscode
    }
    
    /// The actual state variables to use for the UI, initialized to the values of the stored settings
    @State private var labels = MoodOptions.options.moodLabels
    @State private var colors = MoodOptions.options.moodColors
    
    var body: some View {
        
        /// The custom bindings to use to update the settings and the UI with whatever the new values are
        /// Simply having these bindings return the stored value in the Options clas was not working, the values were being overwritten, hence the @State vars above
        let moodLabels = Binding<[String]> {
            labels
        } set: { newValue in
            labels = newValue
            MoodOptions.options.moodLabels = newValue
        }
        
        let moodColors = Binding<[Color]> {
            colors
        } set: { newValue in
            colors = newValue
            MoodOptions.options.moodColors = newValue
        }
        
        NavigationView {
            Form {
                Section("Moods and colors") {
                    
                    ForEach(0..<5) { index in
                        HStack {
                            TextField("Color Label \(index + 1)", text: moodLabels[index])
                                .submitLabel(.done)
                            ColorPicker("Color", selection: moodColors[index], supportsOpacity: false)
                                .labelsHidden()
                                
                        }
                    }
                }
                
                Section("App password") {
                    
                    SecureField("Password", text: $enteredUnlockPasscode.animation())
                        .onAppear {
                            enteredUnlockPasscode = unlockPasscode
                        }
                    
                    if enteredUnlockPasscode != unlockPasscode {
                        SecureField("Confirm Password", text: $confirmUnlockPasscode.animation())
                        
                        if passwordsMatch {
                            Button {
                                if enteredUnlockPasscode == "" {
                                    unlockPasscode = ""
                                } else {
                                    passwordAlertPresented.toggle()
                                }
                            } label: {
                                Label("Change Password", systemImage: "checkmark")
                                    .foregroundColor(.green)
                            }
                            .alert("Set app password?", isPresented: $passwordAlertPresented, actions: {
                                
                                Button("Set", role: .destructive) {
                                    if passwordsMatch {
                                        unlockPasscode = enteredUnlockPasscode
                                        confirmUnlockPasscode = ""
                                    }
                                }
                            }, message: {
                                Text("If you forget your password, you will lose access to the app!")
                            })
                            .buttonStyle(.bordered)
                        } else {
                            Label("Passwords must match", systemImage: "xmark")
                                    .foregroundColor(.red)
                        }
                        
                        
                    }
                    
                    let biometryType = LAContext().biometricType
                    
                    if biometryType != .none {
                        Toggle(isOn: Binding.constant(biometricLocked)) {
                            if biometryType == .faceID {
                                Label("Unlock with FaceID", systemImage: "faceid")
                                    .labelStyle(ColorfulIconLabelStyle(color: .red))
                            } else {
                                Label("Unlock with TouchID", systemImage: "touchid")
                                    .labelStyle(ColorfulIconLabelStyle(color: .red))
                            }
                            
                                
                        }
                        .opacity(unlockPasscode != "" ? 1 : 0.5)
                        .onTapGesture {
                            if unlockPasscode != "" && !biometricLocked {
                                enableBioAuthenticate()
                            } else if unlockPasscode != "" && biometricLocked {
                                biometricLocked = false
                            }
                        }
                    }
                }
                
                Section(footer: Text("It was as if you changed your clock by this amount")) {
                    
                    Stepper(value: $hourOffset, in: -24...24) {
                        Text("Hour offset: \(hourOffset.signum() == 1 ? "+" : "")\(hourOffset)")
                    }
                    
                        
                }
                
                
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "at")
                            .labelStyle(ColorfulIconLabelStyle(color: .orange))
                            
                    }

                }
                
                if developerMode {
                    Section {
                        NavigationLink {
                            DeveloperOptionsView()
                        } label: {

                            Label("Developer", systemImage: "hammer.fill")
                                .labelStyle(ColorfulIconLabelStyle(color: .blue))
                                
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    func getBiometricType() -> LABiometryType {
        let context = LAContext()
        
        return context.biometryType

    }
    
    func enableBioAuthenticate() {
        
        let context = LAContext()
        var error: NSError?
        
        // check whether device authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "Unlock app"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    // authenticated successfully
                    biometricLocked = true
                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics
        }
    }
    
}

/// Adapted from https://stackoverflow.com/a/46887652
extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        var error: NSError?
        
        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch self.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .touchID
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
