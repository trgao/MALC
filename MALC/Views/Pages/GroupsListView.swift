//
//  GroupsListView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct GroupsListView: View {
    private let title: String
    private let items: [MALItem]
    private let group: String
    private let type: TypeEnum
    
    init(_ title: String, _ items: [MALItem], _ group: String, _ type: TypeEnum) {
        self.title = title
        self.items = items
        self.group = group
        self.type = type
    }
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink {
                    GroupDetailsView(item, "\(group)=\(String(item.id))&order_by=popularity&sort=asc", type)
                } label: {
                    Text(item.name)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(title)
        .background(Color(.systemGray6))
    }
}
