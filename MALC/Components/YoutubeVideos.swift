//
//  YoutubeVideos.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import WebKit

struct YoutubeVideos: View {
    private let videos: [Video]?
    
    init(_ videos: [Video]?) {
        self.videos = videos
    }
    
    var body: some View {
        if let videos = videos {
            if !videos.isEmpty {
                VStack {
                    Text("Trailers")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 15)
                        .font(.system(size: 17))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 10)
                                .foregroundColor(.clear)
                            ForEach(videos) { video in
                                YoutubeVideo(video.url)
                            }
                            Rectangle()
                                .frame(width: 10)
                                .foregroundColor(.clear)
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

struct YoutubeVideo: View {
    let url: String?
    
    init(_ url: String?) {
        self.url = url
    }
    
    var body: some View {
        YoutubeVideoFrame(url)
            .frame(width: 245, height: 140)
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
    }
}

struct YoutubeVideoFrame: UIViewRepresentable {
    let url: String?
    
    init(_ url: String?) {
        self.url = url
    }
    
    func makeUIView(context: Context) -> some WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let url = url else {
            return
        }
        uiView.scrollView.isScrollEnabled = false
        let id = url.suffix(11)
        uiView.loadHTMLString("<iframe width=\"245\" height=\"140\" src=\"https://www.youtube.com/embed/\(id)\" title=\"YouTube video player\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" referrerpolicy=\"strict-origin-when-cross-origin\" allowfullscreen style=\"position: absolute;top: 0;left: 0;overflow: hidden;\"></iframe>", baseURL: URL(string: "https://youtube.com")!)
        uiView.configuration.userContentController.addUserScript(self.getZoomDisableScript())
    }
    
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
}
