//
//  WindowSize.swift
//  Moodient
//
//  Created by Smay on 2/9/23.
//

import Foundation
import SwiftUI

// This is awesome
// https://stackoverflow.com/a/71970454

private struct MainWindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var mainWindowSize: CGSize {
        get { self[MainWindowSizeKey.self] }
        set { self[MainWindowSizeKey.self] = newValue }
    }
}
