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
    @StateObject var networker = NetworkManager.shared
    private let toastOptions = SimpleToastOptions(
        alignment: .bottom,
        hideAfter: 5,
        animation: .default,
        modifierType: .scale
    )
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .simpleToast(isPresented: $networker.isExpired, options: toastOptions) {
                    Text("You have been signed out after 1 month of inactivity, please sign in again")
                        .padding(20)
                        .background(.red)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        .padding([.bottom], 60)
                }
        }
    }
}
