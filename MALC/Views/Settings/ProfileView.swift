//
//  ProfileView.swift
//  MALC
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var controller = ProfileViewController()
    @State private var isRefresh = false
    private var user: User
    let networker = NetworkManager.shared
    let dateFormatterPrint = DateFormatter()
    
    init(_ user: User) {
        self.user = user
        self.dateFormatterPrint.dateFormat = "MMM dd, yyyy"
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    if let _ = user.picture {
                        ImageFrame("userImage", 80, 80)
                    }
                    VStack {
                        Text("Hello, \(user.name ?? "")")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 20))
                            .bold()
                        Button("Sign Out") {
                            networker.signOut()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            Section {
                if let animeStatistics = controller.userStatistics?.anime {
                    ForEach(Array(Mirror(reflecting: animeStatistics).children), id: \.label) { child in
                        Text("\(child.label!.camelCaseToWords()): \(child.value)")
                    }
                }
            } header: {
                Text("Anime Statistics")
            }
            Section {
                if let mangaStatistics = controller.userStatistics?.manga {
                    ForEach(Array(Mirror(reflecting: mangaStatistics).children), id: \.label) { child in
                        Text("\(child.label!.camelCaseToWords()): \(child.value)")
                    }
                }
            } header: {
                Text("Manga Statistics")
            } footer: {
                if let date = user.joinedAt {
                    Text("Joined MyAnimeList on \(dateFormatterPrint.string(from: date))")
                        .font(.system(size: 14))
                }
            }
        }
        .task {
            await controller.refresh()
        }
        .task(id: isRefresh) {
            if isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
        .refreshable {
            isRefresh = true
        }
    }
}

