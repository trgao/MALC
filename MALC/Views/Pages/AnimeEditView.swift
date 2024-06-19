//
//  AnimeEditView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI

struct AnimeEditView: View {
    @State private var listStatus: AnimeListStatus
    @State private var isDeleteError = false
    @State private var isDeleting = false
    @State private var isEditError = false
    @Binding private var isPresented: Bool
    private let anime: Anime
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int, _ listStatus: AnimeListStatus?, _ anime: Anime, _ isPresented: Binding<Bool>) {
        self.id = id
        if listStatus == nil {
            self.listStatus = AnimeListStatus(status: .planToWatch, score: 0, numEpisodesWatched: 0)
        } else {
            self.listStatus = listStatus!
        }
        self.anime = anime
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                    Button {
                        networker.editUserAnime(id: anime.id, listStatus: listStatus) { error in
                            if let _ = error {
                                isEditError = true
                            } else {
                                isPresented = false
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(20)
                List {
                    Section {
                        Picker(selection: $listStatus.status, label: Text("Status")) {
                            Text("Watching").tag(StatusEnum.watching as StatusEnum?)
                            Text("Completed").tag(StatusEnum.completed as StatusEnum?)
                            Text("On Hold").tag(StatusEnum.onHold as StatusEnum?)
                            Text("Dropped").tag(StatusEnum.dropped as StatusEnum?)
                            Text("Plan To Watch").tag(StatusEnum.planToWatch as StatusEnum?)
                        }
                        .pickerStyle(.menu)
                        Picker(selection: $listStatus.score, label: Text("Score")) {
                            Text("0 - Not Yet Scored").tag(0)
                            Text("1 - Appalling").tag(1)
                            Text("2 - Horrible").tag(2)
                            Text("3 - Very Bad").tag(3)
                            Text("4 - Bad").tag(4)
                            Text("5 - Average").tag(5)
                            Text("6 - Fine").tag(6)
                            Text("7 - Good").tag(7)
                            Text("8 - Very Good").tag(8)
                            Text("9 - Great").tag(9)
                            Text("10 - Masterpiece").tag(10)
                        }
                        .pickerStyle(.menu)
                        Picker(selection: $listStatus.numEpisodesWatched, label: Text("Episodes Watched")) {
                            ForEach(0...(anime.numEpisodes == 0 ? 5000 : anime.numEpisodes), id: \.self) { number in
                                Text(String(number))
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(anime.status == "not_yet_aired")
                    }
                    Section {
                        if listStatus.startDate != nil {
                            DatePicker(
                                "Start Date",
                                selection: $listStatus.startDate ?? Date(),
                                displayedComponents: [.date]
                            )
                        } else {
                            HStack {
                                Text("Start Date")
                                Spacer()
                                Button {
                                    listStatus.startDate = Date()
                                } label: {
                                    Text("Add start date")
                                }
                            }
                        }
                        if listStatus.finishDate != nil {
                            DatePicker(
                                "Finish Date",
                                selection: $listStatus.finishDate ?? Date(),
                                displayedComponents: [.date]
                            )
                        } else {
                            HStack {
                                Text("Finish Date")
                                Spacer()
                                Button {
                                    listStatus.finishDate = Date()
                                } label: {
                                    Text("Add finish date")
                                }
                            }
                        }
                    }
                }
                .scrollDisabled(true)
                Button {
                    isDeleting = true
                } label: {
                    Label("Remove from list", systemImage: "trash")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(.systemRed))
            }
            .presentationDragIndicator(.visible)
            .background(Color(.systemGray6))
        }
        .alert("Unable to delete", isPresented: $isDeleteError) {
            Button("Ok") {}
        }
        .alert("Unable to edit", isPresented: $isEditError) {
            Button("Ok") {}
        }
        .confirmationDialog("Are you sure?", isPresented: $isDeleting) {
            Button("Confirm", role: .destructive) {
                networker.deleteUserAnime(id: id) { error in
                    if let _ = error {
                        DispatchQueue.main.async {
                            isDeleteError = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            isPresented = false
                        }
                    }
                }
            }
        } message: {
            Text("This will remove this anime from your list")
        }
    }
}
