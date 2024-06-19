//
//  AnimeCreditsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import Foundation

class AnimeCreditsViewController: ObservableObject {
    @Published var staff = [Staff]()
    @Published var isLoading = true
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int) {
        self.id = id
        DispatchQueue.global().async {
            let group = DispatchGroup()
            group.enter()
            self.networker.getAnimeStaff(id: id) { data, error in
                if let data = data {
                    self.staff = data.data
                    for staff in data.data {
                        group.enter()
                        self.networker.downloadImage(id: "person\(staff.id)", urlString: staff.person.images?.jpg.imageUrl) { data,  error in
                            group.leave()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoadingError = true
                    }
                }
                group.leave()
            }
            group.notify(queue: .main, execute: {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            })
        }
    }
}
