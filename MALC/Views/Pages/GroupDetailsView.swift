//
//  GroupDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct GroupDetailsView: View {
    private let item: MALItem
    private let urlExtend: String
    private let type: TypeEnum
    
    init(_ item: MALItem, _ urlExtend: String, _ type: TypeEnum) {
        self.item = item
        self.urlExtend = urlExtend
        self.type = type
    }
    
    var body: some View {
        JikanGridInfiniteScrollView(item.name, urlExtend, type)
    }
}
