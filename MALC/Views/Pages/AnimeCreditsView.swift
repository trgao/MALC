//
//  AnimeCreditsView.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct AnimeCreditsView: View {
    @StateObject var controller: AnimeCreditsViewController
    private let openingThemes: [Theme]?
    private let endingThemes: [Theme]?
    
    init(_ id: Int, _ openingThemes: [Theme]?, _ endingThemes: [Theme]?) {
        self._controller = StateObject(wrappedValue: AnimeCreditsViewController(id))
        self.openingThemes = openingThemes
        self.endingThemes = endingThemes
    }
    
    var body: some View {
        if controller.isLoading {
            LoadingView()
        } else {
            List {
                if let openingThemes = openingThemes {
                    Section("Opening Themes") {
                        ForEach(openingThemes) { theme in
                            Text(theme.text ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        return -20
                    }
                }
                if let endingThemes = endingThemes {
                    Section("Ending Themes") {
                        ForEach(endingThemes) { theme in
                            Text(theme.text ?? "")
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        return -20
                    }
                }
                if !controller.staff.isEmpty {
                    Section("Staff") {
                        ForEach(controller.staff) { staff in
                            NavigationLink {
                                PersonDetailsView(staff.id, staff.person.images?.jpg.imageUrl)
                            } label: {
                                HStack {
                                    ImageFrame("person\(staff.id)", 75, 106)
                                        .padding([.trailing], 10)
                                    VStack(alignment: .leading) {
                                        Text(staff.person.name ?? "")
                                        Text(staff.positions.joined(separator: ", "))
                                            .foregroundStyle(Color(.systemGray))
                                            .font(.system(size: 13))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
