//
//  AnimeInformationBox.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct AnimeInformationBox: View {
    private let anime: Anime
    let dateFormatterPrint = DateFormatter()
    
    init(_ anime: Anime) {
        self.anime = anime
        self.dateFormatterPrint.dateFormat = "MMM dd, yyyy"
    }
    
    var body: some View {
        VStack {
            Text("Information")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing, .top], 5)
                .font(.system(size: 17))
            if anime.source != nil {
                VStack {
                    Text("Source")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(anime.source!.replacingOccurrences(of: "_", with: " ").capitalized)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if anime.rank != nil {
                VStack {
                    Text("Rank")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(String(anime.rank!))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if anime.startSeason != nil && anime.startSeason!.season != nil {
                VStack {
                    Text("Start Season")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(anime.startSeason!.season!.capitalized) of \(String(anime.startSeason!.year!))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if anime.startDate != nil {
                VStack {
                    Text("Aired")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if anime.endDate == nil {
                        Text("\(dateFormatterPrint.string(from: anime.startDate!)) to ?")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("\(dateFormatterPrint.string(from: anime.startDate!)) to \(dateFormatterPrint.string(from: anime.endDate!))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if anime.broadcast != nil && anime.broadcast!.dayOfTheWeek != "other" && anime.broadcast!.startTime != nil {
                VStack {
                    Text("Broadcast")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(anime.broadcast!.dayOfTheWeek.capitalized), \(anime.broadcast!.startTime!) (JST)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if anime.rating != nil {
                VStack {
                    Text("Rating")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(anime.rating!.filter { $0 != "_" }.uppercased())")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if anime.alternativeTitles != nil && anime.alternativeTitles!.ja != nil {
                VStack {
                    Text("Japanese Title")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(anime.alternativeTitles!.ja!)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if !anime.genres.isEmpty {
                VStack {
                    NavigationLink {
                        GroupsListView("Genres", anime.genres, "genres", .anime)
                    } label: {
                        HStack {
                            Text("Genres")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    Text("\(anime.genres.map{ $0.name }.joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
            }
            if !anime.studios.isEmpty {
                VStack {
                    NavigationLink {
                        GroupsListView("Studios", anime.studios, "producers", .anime)
                    } label: {
                        HStack {
                            Text("Studios")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    Text("\(anime.studios.map{ $0.name }.joined(separator: ", "))")
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
