//
//  MALCApp.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

@main
struct MALCApp: App {
    @StateObject var networker = NetworkManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
            .alert(isPresented: $networker.isExpired) {
                Alert(title: Text("You have been signed out"), message: Text("You have been signed out after 1 month of inactivity, please sign in again under Settings"), dismissButton: .default(Text("Ok")))
            }
        }
    }
}
