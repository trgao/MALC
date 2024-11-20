//
//  SettingsView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @StateObject var networker = NetworkManager.shared
    @State private var isAuthenticating = false
    @State private var isAuthenticatingError = false
    
    private func isCancelledLoginError(_ error: Error) -> Bool {
        (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue
    }
    
    private func signIn() {
        Task {
            do {
                isAuthenticating = true
                try await networker.signIn()
                isAuthenticating = false
            } catch let error {
                isAuthenticatingError = true
                isAuthenticating = false
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ZStack {
                        if isAuthenticating {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if !networker.isSignedIn {
                            VStack {
                                Text("Sign in to view or edit lists")
                                Button("Sign In") {
                                    signIn()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(5)
                        } else if let user = networker.user {
                            NavigationLink {
                                ProfileView(user)
                            } label: {
                                HStack {
                                    if let _ = user.picture {
                                        ImageFrame("userImage", 80, 80)
                                    }
                                    VStack {
                                        Text(user.name ?? "")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.system(size: 20))
                                            .bold()
                                        Text("User settings")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(20)
                                }
                            }
                        }
                    }
                }
                Section {
                    NavigationLink {
                        BehavioursView()
                    } label: {
                        Text("Behaviours")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Could not successfully sign in", isPresented: $isAuthenticatingError) {
                Button("Ok") {}
            }
        }
    }
}
