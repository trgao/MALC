//
//  AnimeEditView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI

struct MangaEditView: View {
    @State private var listStatus: MangaListStatus
    @State private var isDeleteError = false
    @State private var isDeleting = false
    @State private var isEditError = false
    @Binding private var isPresented: Bool
    private let manga: Manga
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int, _ listStatus: MangaListStatus?, _ manga: Manga, _ isPresented: Binding<Bool>) {
        self.id = id
        if listStatus == nil {
            self.listStatus = MangaListStatus(status: .planToRead, score: 0, numVolumesRead: 0, numChaptersRead: 0)
        } else {
            self.listStatus = listStatus!
        }
        self.manga = manga
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
                        networker.editUserManga(id: manga.id, listStatus: listStatus) { error in
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
                            Text("Reading").tag(StatusEnum.reading as StatusEnum?)
                            Text("Completed").tag(StatusEnum.completed as StatusEnum?)
                            Text("On Hold").tag(StatusEnum.onHold as StatusEnum?)
                            Text("Dropped").tag(StatusEnum.dropped as StatusEnum?)
                            Text("Plan To Read").tag(StatusEnum.planToRead as StatusEnum?)
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
                        Picker(selection: $listStatus.numVolumesRead, label: Text("Volumes Read")) {
                            ForEach(0...(manga.numVolumes == 0 ? 500 : manga.numVolumes), id: \.self) { number in
                                Text(String(number))
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(manga.status == "not_yet_published")
                        Picker(selection: $listStatus.numChaptersRead, label: Text("Chapters Read")) {
                            ForEach(0...(manga.numChapters == 0 ? 5000 : manga.numChapters), id: \.self) { number in
                                Text(String(number))
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(manga.status == "not_yet_published")
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
                networker.deleteUserManga(id: id) { error in
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
            Text("This will remove this manga from your list")
        }
    }
}
