//
//  ImageFrame.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct ImageFrame: View {
    @StateObject private var controller: ImageFrameController
    private let id: String
    private let width: CGFloat
    private let height: CGFloat
    let networker = NetworkManager.shared
    
    init(_ id: String, _ width: CGFloat, _ height: CGFloat) {
        self._controller = StateObject(wrappedValue: ImageFrameController(id))
        self.id = id
        self.width = width
        self.height = height
    }
    
    var body: some View {
        if controller.isLoading {
            Image(uiImage: UIImage(named: "placeholder.jpg")!)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        } else {
            networker.getImage(id: id)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        }
    }
}
