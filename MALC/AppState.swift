//
//  AppState.swift
//  MALC
//
//  Created by Gao Tianrun on 12/11/24.
//

import Foundation

class AppState: ObservableObject {
    // Keep track of which tabs are already loaded
    @Published var isTopViewFirstLoad = true
    @Published var isSeasonsViewFirstLoad = true
    @Published var isSearchViewFirstLoad = true
    @Published var isMyListViewFirstLoad = true
    
    // Keep track of which tabs are wanting to be refreshed
    @Published var isTopViewRefresh = false
    @Published var isSeasonsViewRefresh = false
    @Published var isSearchViewRefresh = false
    @Published var isMyListViewRefresh = false
    
    // Keep track of the current season and year in the sseasons tab
    @Published var season = ["winter", "spring", "summer", "fall"][((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3]
    @Published var year = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
}
