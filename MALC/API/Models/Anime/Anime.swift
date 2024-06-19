//
//  Anime.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Anime: Codable, Identifiable {
    let id: Int
    let title: String
    let mainPicture: MainPicture?
    let alternativeTitles: AlternativeTitles?
    let startDate: Date?
    let endDate: Date?
    let synopsis: String?
    let mean: Double?
    let rank: Int?
    let mediaType: String
    let status: String
    let genres: [MALItem]
    var myListStatus: AnimeListStatus?
    let numEpisodes: Int
    let startSeason: Season?
    let broadcast: Broadcast?
    let source: String?
    let averageEpisodeDuration: Int?
    let rating: String?
    let studios: [MALItem]
    let openingThemes: [Theme]?
    let endingThemes: [Theme]?
    let videos: [Video]?
    let recommendations: [MALListAnime]
}
