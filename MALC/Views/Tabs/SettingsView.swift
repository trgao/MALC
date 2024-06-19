//
//  SettingsView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                SignInOutBox()
            }
            .navigationTitle("Settings")
        }
    }
}
