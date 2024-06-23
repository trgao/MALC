//
//  AnimeMangaListItem.swift
//  MALC
//
//  Created by Gao Tianrun on 15/5/24.
//

import SwiftUI

struct AnimeMangaListItem: View {
    @State private var isEditViewPresented = false
    private let id: Int
    private let title: String?
    private let type: TypeEnum
    private let status: StatusEnum
    private let numEpisodes: Int?
    private let numVolumes: Int?
    private let numChapters: Int?
    private let animeListStatus: AnimeListStatus?
    private let mangaListStatus: MangaListStatus?
    private let colours: [StatusEnum:Color] = [
        .reading: Color(.systemGreen),
        .watching: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToWatch: Color(.systemGray),
        .planToRead: Color(.systemGray),
        .none: Color(.systemBlue)
    ]
    private let refresh: () -> Void
    let networker = NetworkManager.shared
    
    init(_ id: Int, _ title: String?, _ type: TypeEnum) {
        self.id = id
        self.title = title
        self.type = type
        self.status = .none
        self.numEpisodes = nil
        self.numVolumes = nil
        self.numChapters = nil
        self.animeListStatus = nil
        self.mangaListStatus = nil
        self.refresh = {}
    }
    
    init(_ id: Int, _ title: String?, _ type: TypeEnum, _ status: StatusEnum, _ numEpisodes: Int?, _ animeListStatus: AnimeListStatus?, _ refresh: @escaping () -> Void) {
        self.id = id
        self.title = title
        self.type = type
        self.status = status
        self.numEpisodes = numEpisodes
        self.numVolumes = nil
        self.numChapters = nil
        self.animeListStatus = animeListStatus
        self.mangaListStatus = nil
        self.refresh = refresh
    }
    
    init(_ id: Int, _ title: String?, _ type: TypeEnum,  _ status: StatusEnum, _ numVolumes: Int?, _ numChapters: Int?, _ mangaListStatus: MangaListStatus?, _ refresh: @escaping () -> Void) {
        self.id = id
        self.title = title
        self.type = type
        self.status = status
        self.numEpisodes = nil
        self.numVolumes = numVolumes
        self.numChapters = numChapters
        self.animeListStatus = nil
        self.mangaListStatus = mangaListStatus
        self.refresh = refresh
    }
    
    var body: some View {
        NavigationLink {
            if type == .anime {
                AnimeDetailsView(id)
            } else {
                MangaDetailsView(id)
            }
        } label: {
            HStack {
                ImageFrame("\(type)\(id)", 75, 106)
                VStack(alignment: .leading) {
                    Text(title ?? "")
                        .bold()
                        .font(.system(size: 16))
                    if type == .anime, let numEpisodesWatched = animeListStatus?.numEpisodesWatched {
                        if let numEpisodes = numEpisodes, numEpisodes > 0 {
                            VStack(alignment: .leading) {
                                ProgressView(value: Float(numEpisodesWatched) / Float(numEpisodes))
                                    .tint(colours[status])
                                Label("\(String(numEpisodesWatched)) / \(String(numEpisodes))", systemImage: "video.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabel(spacing: 1))
                            }
                        } else {
                            VStack(alignment: .leading) {
                                ProgressView(value: numEpisodesWatched == 0 ? 0 : 0.5)
                                    .tint(colours[status])
                                Label("\(String(numEpisodesWatched)) / ?", systemImage: "video.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabel(spacing: 1))
                            }
                        }
                    } else if type == .manga, let numChaptersRead = mangaListStatus?.numChaptersRead, let numVolumesRead = mangaListStatus?.numVolumesRead {
                        if let numChapters = numChapters, numChapters > 0 {
                            VStack(alignment: .leading) {
                                ProgressView(value: Float(numChaptersRead) / Float(numChapters))
                                    .tint(colours[status])
                                HStack {
                                    if let numVolumes = numVolumes, numVolumes > 0 {
                                        Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 1))
                                    } else {
                                        Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 1))
                                    }
                                    Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color(.systemGray))
                                        .labelStyle(CustomLabel(spacing: 1))
                                }
                            }
                        } else {
                            VStack(alignment: .leading) {
                                ProgressView(value: numChaptersRead == 0 ? 0 : 0.5)
                                    .tint(colours[status])
                                HStack {
                                    if let numVolumes = numVolumes, numVolumes > 0 {
                                        Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 1))
                                    } else {
                                        Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 1))
                                    }
                                    Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color(.systemGray))
                                        .labelStyle(CustomLabel(spacing: 1))
                                }
                            }
                        }
                    }
                    HStack {
                        if type == .anime, let score = animeListStatus?.score, score > 0 {
                            Text("\(score) ⭐")
                                .bold()
                                .font(.system(size: 13))
                                .padding(.top, 3)
                        } else if type == .manga, let score = mangaListStatus?.score, score > 0 {
                            Text("\(score) ⭐")
                                .bold()
                                .font(.system(size: 13))
                                .padding(.top, 3)
                        }
                        Spacer()
                        if networker.isSignedIn && (animeListStatus != nil || mangaListStatus != nil) {
                            Button {
                                isEditViewPresented = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .foregroundStyle(Color(.systemBlue))
                            .sheet(isPresented: $isEditViewPresented) {
                                refresh()
                            } content: {
                                if type == .anime {
                                    AnimeEditView(id, animeListStatus, title!, numEpisodes!, $isEditViewPresented)
                                } else if type == .manga {
                                    MangaEditView(id, mangaListStatus, title!, numVolumes!, numChapters!, $isEditViewPresented)
                                }
                            }
                        }
                    }
                }
                .padding(5)
            }
        }
        .buttonStyle(.plain)
        .padding(5)
    }
}
