//
//  YearPicker.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct YearPicker: View {
    @EnvironmentObject var appState: AppState
    @StateObject var controller: SeasonsViewController
    @State private var year = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
    private let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
    
    init(_ controller: SeasonsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        Menu {
            Picker(selection: $appState.year, label: EmptyView()) {
                ForEach((1917...currentYear + 1).reversed(), id: \.self) { year in
                    Text(String(year)).tag(String(year))
                }
            }
            .task(id: appState.year) {
                if appState.year != year {
                    year = appState.year
                    await controller.changeYear(appState.year)
                }
            }
        } label: {
            Button(String(appState.year)) {}
                .buttonStyle(.borderedProminent)
        }
        .onAppear {
            self.year = appState.year
        }
    }
}
