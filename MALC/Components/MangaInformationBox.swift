//
//  MangaInformationBox.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaInformationBox: View {
    private let manga: Manga
    let dateFormatterPrint = DateFormatter()
    
    init(_ manga: Manga) {
        self.manga = manga
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
    }
    
    var body: some View {
        VStack {
            Text("Information")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing, .top], 5)
                .font(.system(size: 17))
            if manga.rank != nil {
                VStack {
                    Text("Rank")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(String(manga.rank!))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if manga.startDate != nil {
                VStack {
                    Text("Published")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if manga.endDate == nil {
                        Text("\(dateFormatterPrint.string(from: manga.startDate!)) to ?")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("\(dateFormatterPrint.string(from: manga.startDate!)) to \(dateFormatterPrint.string(from: manga.endDate!))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if manga.alternativeTitles != nil && manga.alternativeTitles!.ja != nil {
                VStack {
                    Text("Japanese Title")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(manga.alternativeTitles!.ja!)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if !manga.genres.isEmpty {
                VStack {
                    NavigationLink {
                        GroupsListView("Genres", manga.genres, "genres", .manga)
                    } label: {
                        HStack {
                            Text("Genres")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    Text("\(manga.genres.map{ $0.name }.joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
        }
        .padding(10)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 0.5)
        .frame(maxWidth: .infinity)
        .padding(15)
        .font(.system(size: 12))
    }
}
