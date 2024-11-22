//
//  ProfileViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 22/11/24.
//

import Foundation

@MainActor
class ProfileViewController: ObservableObject {
    @Published var userStatistics: UserStatistics?
    @Published var isLoadingError = false
    let networker = NetworkManager.shared
    
    func refresh() async -> Void {
        do {
            let userStatistics = try await networker.getUserStatistics()
            self.userStatistics = userStatistics
        } catch {
            isLoadingError = true
        }
    }
}
