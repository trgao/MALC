//
//  LoadingView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 130, height: 100)
                .foregroundColor(Color(hex: 0x2e2e2e))
            ProgressView {
                Text("Loading")
                    .foregroundColor(.white)
            }
            .tint(.white)
        }
    }
}
