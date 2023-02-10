//
//  SelectedTabExtension.swift
//  Moodient
//
//  Created by Smay on 2/9/23.
//

import Foundation
import SwiftUI

private struct SelectedTabTitle: EnvironmentKey {
    static let defaultValue: String = ""
}

extension EnvironmentValues {
    var selectedTabTitle: String {
        get { self[SelectedTabTitle.self] }
        set { self[SelectedTabTitle.self] = newValue }
    }
}
