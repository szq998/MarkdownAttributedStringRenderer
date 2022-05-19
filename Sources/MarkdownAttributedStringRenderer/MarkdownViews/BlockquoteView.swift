//
//  BlockquoteView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct BlockquoteView: View {
    let blockquoteBlock: BlockquoteBlock
    
    var children: some View {
        VStack(alignment: .leading, spacing: 5) {
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
