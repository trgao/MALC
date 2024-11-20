//
//  ListFilter.swift
//  MALC
//
//  Created by Gao Tianrun on 18/5/24.
//

import SwiftUI

struct ListFilter: View {
    @StateObject var controller: MyListViewController
    
    init(_ controller: MyListViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        Menu {
            if controller.type == .anime {
                Picker(selection: $controller.animeStatus, label: EmptyView()) {
                    Text("All").tag(StatusEnum.none)
                    Text("Watching").tag(StatusEnum.watching)
                    Text("Completed").tag(StatusEnum.completed)
                    Text("On Hold").tag(StatusEnum.onHold)
                    Text("Dropped").tag(StatusEnum.dropped)
                    Text("Plan To Watch").tag(StatusEnum.planToWatch)
                }
                .onChange(of: controller.animeStatus) { _ in
                    Task {
                        await controller.refresh(true)
                    }
                }
                Divider()
                Picker(selection: $controller.animeSort, label: EmptyView()) {
                    Text("By Score").tag("list_score")
                    Text("By Last Update").tag("list_updated_at")
                    Text("By Title").tag("anime_title")
                    Text("By Start Date").tag("anime_start_date")
                }
                .onChange(of: controller.animeSort) { _ in
                    Task {
                        await controller.refresh(true)
                    }
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaStatus, label: EmptyView()) {
                    Text("All").tag(StatusEnum.none)
                    Text("Reading").tag(StatusEnum.reading)
                    Text("Completed").tag(StatusEnum.completed)
                    Text("On Hold").tag(StatusEnum.onHold)
                    Text("Dropped").tag(StatusEnum.dropped)
                    Text("Plan To Read").tag(StatusEnum.planToRead)
                }
                .onChange(of: controller.mangaStatus) { _ in
                    Task {
                        await controller.refresh(true)
                    }
                }
                Divider()
                Picker(selection: $controller.mangaSort, label: EmptyView()) {
                    Text("By Score").tag("list_score")
                    Text("By Last Update").tag("list_updated_at")
                    Text("By Title").tag("manga_title")
                    Text("By Start Date").tag("manga_start_date")
                }
                .onChange(of: controller.mangaSort) { _ in
                    Task {
                        await controller.refresh(true)
                    }
                }
            }
        } label: {
            Button{} label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
}
