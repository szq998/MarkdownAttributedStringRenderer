//
//  BlockquoteView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct BlockquoteView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var paragraphSpacing: CGFloat { (20 / 17) * dynamicTypeSize.bodyFontSize }
    
    let blockquoteBlock: BlockquoteBlock
    var children: some View {
        VStack(alignment: .leading, spacing: paragraphSpacing) {
            ForEach(blockquoteBlock.children, id: \.id) { child in
                renderMarkdownBlock(child)
            }
        }
    }
    
    var body: some View {
        children
            .makeBlockquote(isOutermost: blockquoteBlock.isOutermost)
    }
}
