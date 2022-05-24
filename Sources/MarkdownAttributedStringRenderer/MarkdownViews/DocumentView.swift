//
//  DocumentView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct DocumentView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var paragraphSpacing: CGFloat { (20 / 17) * dynamicTypeSize.bodyFontSize }
    
    let document: Document
    var children: some View {
        VStack(alignment: .leading, spacing: paragraphSpacing) {
            ForEach(document.children, id: \.id) { child in
                renderMarkdownBlock(child)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        children
    }
}

extension DynamicTypeSize {
    var bodyFontSize: CGFloat {
        switch self {
        case .xSmall:
            return 14
        case .small:
            return 15
        case .medium:
            return 16
        case .large:
            return 17
        case .xLarge:
            return 19
        case .xxLarge:
            return 21
        case .xxxLarge:
            return 23
        case .accessibility1:
            return 28
        case .accessibility2:
            return 33
        case .accessibility3:
            return 40
        case .accessibility4:
            return 47
        case .accessibility5:
            return 53
        @unknown default:
            return 17
        }

    }
}
