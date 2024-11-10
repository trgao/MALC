//
//  SignInOutBox.swift
//  MALC
//
//  Created by Gao Tianrun on 15/5/24.
//

import SwiftUI
import AuthenticationServices

struct SignInOutBox: View {
    @StateObject var networker = NetworkManager.shared
    @State private var isAuthenticating = false
    @State private var isAuthenticatingError = false
    
    private func isCancelledLoginError(_ error: Error) -> Bool {
        (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 80)
                .padding(10)
                .foregroundStyle(Color(.systemBackground))
            if isAuthenticating {
                ProgressView()
            } else if !networker.isSignedIn {
                VStack {
                    Text("You have to sign in to view or edit your lists")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16))
                        .padding([.bottom], 10)
                    Button("Sign In") {
                        isAuthenticating = true
                        networker.signIn() { error in
                            isAuthenticating = false
                            if let error, !isCancelledLoginError(error) {
                                isAuthenticatingError = true
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let user = networker.user {
                HStack {
                    ImageFrame("userImage", 80, 80)
                    VStack {
                        Text("Hello, \(user.name ?? "")")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 20))
                            .bold()
                        Button("Sign Out") {
                            networker.signOut()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .alert("Could not successfully sign in", isPresented: $isAuthenticatingError) {
            Button("Ok") {}
        }
    }
}
