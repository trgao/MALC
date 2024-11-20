//
//  SeasonPicker.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct SeasonPicker: View {
    @StateObject var controller: SeasonsViewController
    @State private var season = ["winter", "spring", "summer", "fall"][((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3]
    
    init(_ controller: SeasonsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 40)
                .foregroundColor(Color(uiColor: .systemGray6))
            Picker(selection: $controller.season, label: EmptyView()) {
                Text("Winter").tag("winter")
                Text("Spring").tag("spring")
                Text("Summer").tag("summer")
                Text("Fall").tag("fall")
            }
            .onChange(of: controller.season) { _ in
                if controller.isSeasonEmpty() {
                    Task {
                        await controller.refresh()
                    }
                }
            }
            .pickerStyle(.segmented)
            .padding(5)
        }
        .padding(5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .disabled(controller.isLoading)
    }
}
