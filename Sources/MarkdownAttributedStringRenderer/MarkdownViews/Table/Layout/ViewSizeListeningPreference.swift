//
//  ViewSizeListeningPreference.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct ViewSizeKey: PreferenceKey {
    static let defaultValue = CGSize.zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeListening: ViewModifier {
    @State var size = CGSize.zero
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo  in
                    Color.clear
                    // cannot directly use ".preferece(key: ViewSizeKey.self, value: geo.size)"
                    // or you will only get zero size
                    // trick to prevent zero size from geometry reader
                        .onChange(of: geo.size) { newSize in
                            size = newSize
                        }
                }
            )
            .preference(key: ViewSizeKey.self, value: size)
    }
}

extension View {
    func sizeListening() -> some View {
        modifier(SizeListening())
    }
    func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
        self
            .sizeListening()
            .onPreferenceChange(ViewSizeKey.self, perform: perform)
    }
}
