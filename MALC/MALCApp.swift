//
//  MALCApp.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

@main
struct MALCApp: App {
    @StateObject var appState = AppState()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
        }
    }
}
