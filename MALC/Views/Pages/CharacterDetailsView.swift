//
//  CharacterDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import SwiftUI

struct CharacterDetailsView: View {
    @StateObject var controller: CharacterDetailsViewController
    private let id: Int
    private let imageUrl: String?
    
    init (_ id: Int, _ imageUrl: String?) {
        self.id = id
        self.imageUrl = imageUrl
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoading {
                LoadingView()
            } else if let character = controller.character {
                List {
                    Section {
                        VStack(alignment: .center) {
                            ImageFrame("character\(character.id)", 150, 212)
                                .padding([.top], 10)
                            Text("\(character.name ?? "")")
                                .bold()
                                .font(.system(size: 25))
                                .padding(.horizontal, 10)
                                .multilineTextAlignment(.center)
                            Text("\(character.nameKanji ?? "")")
                                .padding(.horizontal, 10)
                                .font(.system(size: 18))
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                    } header: {
                        Text("")
                    }
                    if let about = character.about {
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
                    CharacterAnimeSection(character.anime)
                    CharacterMangaSection(character.manga)
                    CharacterVoiceSection(character.voices)
                }
                .shadow(radius: 0.5)
                .background(Color(.systemGray6))
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Unable to load", isPresented: $controller.isLoadingError) {
            Button("Ok") {}
        }
    }
}

struct CharacterAnimeSection: View {
    private let animes: [Animeography]
    
    init(_ animes: [Animeography]) {
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
                                Text(anime.role)
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                Text("Animes")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct CharacterMangaSection: View {
    private let mangas: [Mangaography]
    
    init(_ mangas: [Mangaography]) {
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
                                Text(manga.role)
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                Text("Mangas")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct CharacterVoiceSection: View {
    private let voices: [Voice]
    
    init(_ voices: [Voice]) {
        self.voices = voices
    }
    
    var body: some View {
        if !voices.isEmpty {
            Section {
                ForEach(voices) { voice in
                    NavigationLink {
                        PersonDetailsView(voice.id, voice.person.images?.jpg.imageUrl)
                    } label: {
                        HStack {
                            ImageFrame("person\(voice.id)", 75, 106)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(voice.person.name ?? "")
                                Text(voice.language)
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                Text("Voices")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}
