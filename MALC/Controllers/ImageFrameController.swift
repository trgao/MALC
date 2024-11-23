//
//  ImageFrameController.swift
//  MALC
//
//  Created by Gao Tianrun on 11/11/24.
//

import Foundation

@MainActor
class ImageFrameController: ObservableObject {
    @Published var isLoading = false
    private let id: String
    let networker = NetworkManager.shared
    
    init(_ id: String) {
        self.id = id
        
        // Check if image is in cache
        if let _ = networker.imageCache.object(forKey: id as NSString) {}
        else {
            isLoading = true
            Task {
                await networker.downloadImage(id: id, urlString: networker.imageUrlMap[id])
                isLoading = false
            }
        }
    }
}
