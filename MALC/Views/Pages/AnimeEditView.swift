//
//  AnimeEditView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI
import SimpleToast

struct AnimeEditView: View {
    @State private var listStatus: AnimeListStatus
    @State private var isDeleteError = false
    @State private var isDeleting = false
    @State private var isEditError = false
    @Binding private var isPresented: Bool
    private let title: String
    private let numEpisodes: Int
    private let id: Int
    private let hasWatched: Bool
    let networker = NetworkManager.shared
    
    init(_ id: Int, _ listStatus: AnimeListStatus?, _ title: String, _ numEpisodes: Int, _ isPresented: Binding<Bool>) {
        self.id = id
        if listStatus == nil {
            self.listStatus = AnimeListStatus(status: .planToWatch, score: 0, numEpisodesWatched: 0)
        } else {
            self.listStatus = listStatus!
        }
        self.title = title
        self.numEpisodes = numEpisodes
        self._isPresented = isPresented
        self.hasWatched = listStatus == nil || listStatus?.status == .planToWatch
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
                        networker.editUserAnime(id: id, listStatus: listStatus) { error in
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
                Text(title)
                    .font(.system(size: 20))
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
                            ForEach(0...(numEpisodes == 0 ? 5000 : numEpisodes), id: \.self) { number in
                                Text(String(number))
                            }
                        }
                        .pickerStyle(.menu)
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
        .simpleToast(isPresented: $isDeleteError, options: alertToastOptions) {
            Text("Unable to delete")
                .padding(20)
                .background(.red)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .simpleToast(isPresented: $isEditError, options: alertToastOptions) {
            Text("Unable to save")
                .padding(20)
                .background(.red)
                .foregroundStyle(.white)
                .cornerRadius(10)
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
