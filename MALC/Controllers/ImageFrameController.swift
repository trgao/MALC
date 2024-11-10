//
//  ImageFrameController.swift
//  MALC
//
//  Created by Gao Tianrun on 11/11/24.
//

import Foundation

class ImageFrameController: ObservableObject {
    @Published var isLoading = false
    private let id: String
    let networker = NetworkManager.shared
    
    init(_ id: String) {
        self.id = id
        if let _ = networker.imageCache.object(forKey: id as NSString) {}
        else {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            networker.downloadImage(id: id, urlString: networker.imageUrlMap[id]) { data, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
