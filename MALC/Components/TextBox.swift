//
//  TextBox.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct TextBox: View {
    @State private var isExpanded = false
    @State private var canBeExpanded = false
    private let title: String
    private let text: String?
    
    init(_ title: String, _ text: String?) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
        if let text = text {
            VStack {
                Text(title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing, .top], 5)
                    .font(.system(size: 17))
                Text(text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isExpanded ? nil : 4)
                    .background {
                        ViewThatFits(in: .vertical) {
                            Text(text)
                                .hidden()
                            Color.clear
                                .onAppear {
                                    canBeExpanded = true
                                }
                        }
                    }
                    .padding(5)
                    .font(.system(size: 16))
                    .lineSpacing(2)
                if canBeExpanded {
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        if isExpanded {
                            Image(systemName: "chevron.up")
                        } else {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .buttonStyle(ChevronButtonStyle(isEnabled: isExpanded))
                    .frame(width: 30, height: 30)
                }
            }
            .padding(10)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 0.5)
            .frame(maxWidth: .infinity)
            .padding(15)
        }
    }
}

private struct ChevronButtonStyle: ButtonStyle {
    let isEnabled: Bool

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.clear)
    }
}
