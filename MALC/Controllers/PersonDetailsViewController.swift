//
//  PersonDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

class PersonDetailsViewController: ObservableObject {
    @Published var person: Person?
    @Published var isLoading = true
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int) {
        self.id = id
        networker.getPersonDetails(id: id) { data, error in
            if let data = data {
                self.person = data.data
                DispatchQueue.global().async {
                    let group = DispatchGroup()
                    for voice in data.data.voices {
                        group.enter()
                        self.networker.downloadImage(id: "anime\(voice.anime.id)", urlString: voice.anime.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    for anime in data.data.anime {
                        group.enter()
                        self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.anime.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    for manga in data.data.manga {
                        group.enter()
                        self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.manga.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                       DispatchQueue.main.async {
                           self.isLoading = false
                       }
                   })
                }
                return
            } else {
                DispatchQueue.main.async {
                    self.isLoadingError = true
                    self.isLoading = false
                }
            }
        }
    }
}
