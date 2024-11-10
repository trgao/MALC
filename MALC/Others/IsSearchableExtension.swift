//
//  IsSearchableExtension.swift
//  Code taken from https://gist.github.com/marcoarment/19318a17ede162b4de5c853f49ca482c
//

import SwiftUI

extension View {
    public func searchable_ios16(text: Binding<String>, isPresented: Binding<Bool>, prompt: String) -> some View {
        modifier(Searchable_iOS16(text: text, isPresented: isPresented, prompt: prompt))
    }
}

public struct Searchable_iOS16: ViewModifier {
    @Binding var text: String
    @Binding var isPresented: Bool
    @State var legacyIsSearching = false
    var prompt: String

    public func body(content: Content) -> some View {
        #if os(watchOS) || os(tvOS)
            bodyLegacy(content)
        #else
            if #available(iOS 17, macOS 14, *) {
                bodyModern(content)
            } else {
                bodyLegacy(content)
            }
        #endif
    }

    @available(iOS 17, macOS 14, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func bodyModern(_ content: Content) -> some View {
        content
            .searchable(text: $text, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
    }

    public func bodyLegacy(_ content: Content) -> some View {
        SearchableInner_iOS16(legacyIsSearching: $legacyIsSearching) {
            content
        }
        .searchable(text: $text, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
        .onChange(of: legacyIsSearching) { isPresented = $0 }
        .onAppear { isPresented = legacyIsSearching }
    }
}

struct SearchableInner_iOS16<Content: View>: View {
    @Environment(\.isSearching) private var environmentIsSearching
    @Binding var legacyIsSearching: Bool
    var content: () -> Content

    init(legacyIsSearching: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._legacyIsSearching = legacyIsSearching
        self.content = content
    }
    
    var body: some View {
        content()
        .onChange(of: environmentIsSearching) { legacyIsSearching = $0 }
        .onAppear { legacyIsSearching = environmentIsSearching }
    }
}
