//
//  SafariView.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    private let url: URL
    
    init(_ url: URL) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {

    }
}
