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
    @Published var isLoading = false
    @Published var isLoadingError = false
    let networker = NetworkManager.shared
    
    func refresh() async -> Void {
        isLoading = true
        do {
            let userStatistics = try await networker.getUserStatistics()
            self.userStatistics = userStatistics
            isLoading = false
        } catch {
            isLoading = false
            isLoadingError = true
        }
    }
}
