//
//  PersonDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import SwiftUI
import SimpleToast

struct PersonDetailsView: View {
    @StateObject var controller: PersonDetailsViewController
    @State private var isRefresh = false
    private let id: Int
    private let imageUrl: String?
    let dateFormatterPrint = DateFormatter()
    
    init (_ id: Int, _ imageUrl: String?) {
        self.id = id
        self.imageUrl = imageUrl
        self._controller = StateObject(wrappedValue: PersonDetailsViewController(id))
        self.dateFormatterPrint.dateFormat = "MMM dd, yyyy"
    }
    
    var body: some View {
        ZStack {
            if controller.isLoading {
                LoadingView()
            }
            if let person = controller.person {
                List {
                    Section {
                        VStack(alignment: .center) {
                            ImageFrame("person\(person.id)", 150, 212)
                                .padding([.top], 10)
                            Text("\(person.name)")
                                .bold()
                                .font(.system(size: 25))
                                .padding(.horizontal, 10)
                                .multilineTextAlignment(.center)
                            if let birthday = person.birthday {
                                Text("Birthday: \(dateFormatterPrint.string(from: birthday))")
                                    .padding(.horizontal, 10)
                                    .font(.system(size: 18))
                                    .opacity(0.7)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                    } header: {
                        Text("")
                    }
                    if let about = person.about {
                        VStack {
                            Text("About")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading, .trailing, .top], 5)
                                .font(.system(size: 17))
                            Text(about)
                                .multilineTextAlignment(.leading)
                                .padding(5)
                                .font(.system(size: 16))
                                .lineSpacing(2)
                        }
                    }
                    PersonVoiceSection(person.voices)
                    PersonAnimeSection(person.anime)
                    PersonMangaSection(person.manga)
                }
                .shadow(radius: 0.5)
                .background(Color(.systemGray6))
                .scrollContentBackground(.hidden)
                .task(id: isRefresh) {
                    if isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .refreshable {
                    isRefresh = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
            Text("Unable to load")
                .padding(20)
                .background(.red)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .task {
            await controller.refresh()
        }
    }
}

struct PersonVoiceSection: View {
    private let voices: [AnimeVoice]
    
    init(_ voices: [AnimeVoice]) {
        self.voices = voices
    }
    
    var body: some View {
        if !voices.isEmpty {
            Section {
                ForEach(voices) { voice in
                    NavigationLink {
                        AnimeDetailsView(voice.anime.id)
                    } label: {
                        HStack {
                            ImageFrame("anime\(voice.anime.id)", 75, 106)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(voice.anime.title ?? "")
                                Text(voice.character.name ?? "")
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                Text("Voice Acting Roles")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct PersonAnimeSection: View {
    private let animes: [AnimePosition]
    
    init(_ animes: [AnimePosition]) {
        self.animes = animes
    }
    
    var body: some View {
        if !animes.isEmpty {
            Section {
                ForEach(animes) { anime in
                    NavigationLink {
                        AnimeDetailsView(anime.id)
                    } label: {
                        HStack {
                            ImageFrame("anime\(anime.id)", 75, 106)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(anime.anime.title ?? "")
                                Text(anime.position.suffix(anime.position.count - 4))
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                Text("Anime Staff Positions")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct PersonMangaSection: View {
    private let mangas: [MangaPosition]
    
    init(_ mangas: [MangaPosition]) {
        self.mangas = mangas
    }
    
    var body: some View {
        if !mangas.isEmpty {
            Section {
                ForEach(mangas) { manga in
                    NavigationLink {
                        MangaDetailsView(manga.id)
                    } label: {
                        HStack {
                            ImageFrame("manga\(manga.id)", 75, 106)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(manga.manga.title ?? "")
                                Text(manga.position.suffix(manga.position.count - 4))
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                Text("Manga Staff Positions")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}
