//
//  CustomLabel.swift
//  Code taken from https://www.hackingwithswift.com/forums/swiftui/reduce-the-space-between-a-label-s-title-and-icon/22983/22984
//

import SwiftUI

struct CustomLabel: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
