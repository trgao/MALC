//
//  MangaDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI
import SimpleToast

struct MangaDetailsView: View {
    @StateObject var controller: MangaDetailsViewController
    @State private var synopsisLines = 4
    @State private var isShowingMore = false
    @State private var isShowingSafariView = false
    @State private var isEditViewPresented = false
    private let id: Int
    private let url: URL
    let networker = NetworkManager.shared
    
    init(_ id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: MangaDetailsViewController(id))
        self.url = URL(string: "https://myanimelist.net/manga/\(id)")!
    }
    
    var body: some View {
        ZStack {
            if controller.isInitialLoading {
                LoadingView()
            } else if let manga = controller.manga {
                ScrollView {
                    VStack(alignment: .center) {
                        ImageFrame("manga\(manga.id)", 150, 212)
                            .padding([.top], 10)
                        Text("\(manga.title)")
                            .bold()
                            .font(.system(size: 25))
                            .padding(10)
                            .multilineTextAlignment(.center)
                        HStack {
                            VStack {
                                if let myScore = manga.myListStatus?.score, myScore > 0 {
                                    Text("MAL score:")
                                        .font(.system(size: 13))
                                }
                                Text("\(manga.mean == nil ? "N/A" : String(manga.mean!)) ⭐")
                            }
                            if let myScore = manga.myListStatus?.score, myScore > 0 {
                                VStack {
                                    Text("Your score:")
                                        .font(.system(size: 13))
                                    Text("\(myScore) ⭐")
                                }
                                .padding(.leading, 20)
                            }
                        }
                        .padding([.bottom], 5)
                        .bold()
                        .font(.system(size: 25))
                        VStack {
                            Text("\(manga.mediaType.replacingOccurrences(of: "_", with: " ").capitalized) ・ \(manga.status.replacingOccurrences(of: "_", with: " ").capitalized)")
                            Text("\(manga.numVolumes == 0 ? "?" : String(manga.numVolumes)) volumes, \(manga.numChapters == 0 ? "?" : String(manga.numChapters)) chapters")
                        }
                        .opacity(0.7)
                        .font(.system(size: 12))
                        TextBox("Synopsis", manga.synopsis)
                        Characters(controller.characters)
                        RelatedItems(controller.relations)
                        Recommendations(manga.recommendations)
                        MangaInformationBox(manga)
                    }
                }
            }
            if controller.isLoading {
                LoadingView()
            }
        }
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
            Text("Unable to load")
                .padding(20)
                .background(.red)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .fullScreenCover(isPresented: $isShowingSafariView) {
            SafariView(url)
        }
        .toolbar {
            if networker.isSignedIn {
                if let manga = controller.manga {
                    Button {
                        isEditViewPresented = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .sheet(isPresented: $isEditViewPresented) {
                        controller.refresh()
                    } content: {
                        MangaEditView(id, manga.myListStatus, manga.title, manga.numVolumes, manga.numChapters, $isEditViewPresented)
                    }
                    .disabled(controller.isLoading || controller.isInitialLoading)
                } else {
                    Button {} label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(true)
                }
            }
            Menu {
                ShareLink("Share", item: url)
                Button {
                    isShowingSafariView = true
                } label: {
                    Label("Open MyAnimeList page", systemImage: "globe")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}
