//
//  TitleText.swift
//  Hako
//
//  Created by Gao Tianrun on 7/6/24.
//

import SwiftUI

struct TitleText: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    private let romaji: String
    private let english: String?
    private let japanese: String?
    
    init(romaji: String, english: String? = nil, japanese: String? = nil) {
        self.romaji = romaji
        self.english = english
        self.japanese = japanese
    }
    
    var text: some View {
        VStack {
            if let title = english, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                Text(title)
                    .bold()
                    .font(.system(size: 25))
                    .multilineTextAlignment(.center)
            } else {
                Text(romaji)
                    .bold()
                    .font(.system(size: 25))
                    .multilineTextAlignment(.center)
            }
            if let japanese = japanese {
                Text(japanese)
                    .padding(.bottom, 5)
                    .font(.system(size: 18))
                    .opacity(0.7)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.black.opacity(0.000000001))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var body: some View {
        text
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
            .contextMenu {
                Button {
                    UIPasteboard.general.string = romaji
                } label: {
                    Text("Copy Romaji title")
                    Text(romaji)
                }
                if let english = english, !english.isEmpty {
                    Button {
                        UIPasteboard.general.string = english
                    } label: {
                        Text("Copy English title")
                        Text(english)
                    }
                }
                if let japanese = japanese, !japanese.isEmpty {
                    Button {
                        UIPasteboard.general.string = japanese
                    } label: {
                        Text("Copy native language title")
                        Text(japanese)
                    }
                }
            }
    }
}
