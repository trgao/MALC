//
//  ProfileView.swift
//  MALC
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    private var user: User
    let networker = NetworkManager.shared
    let dateFormatterPrint = DateFormatter()
    
    init(_ user: User) {
        self.user = user
        self.dateFormatterPrint.dateFormat = "MMM dd, yyyy"
    }
    
    var body: some View {
        HStack {
            if let _ = user.picture {
                ImageFrame("userImage", 80, 80)
            }
            VStack {
                Text("Hello, \(user.name ?? "")")
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 20))
                    .bold()
                if let date = user.joinedAt {
                    Text("Joined on \(dateFormatterPrint.string(from: date))")
                        .padding(1)
                        .font(.system(size: 14))
                }
                Button("Sign Out") {
                    networker.signOut()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

