//
//  ImageFrame.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct ImageFrame: View {
    private let id: String
    private let width: CGFloat
    private let height: CGFloat
    let networker = NetworkManager.shared
    
    init(_ id: String, _ width: CGFloat, _ height: CGFloat) {
        self.id = id
        self.width = width
        self.height = height
    }
    
    var body: some View {
        networker.getImage(id: id)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 2)
    }
}
