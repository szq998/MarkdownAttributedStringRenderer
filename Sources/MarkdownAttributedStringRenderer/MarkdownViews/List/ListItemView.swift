//
//  MarkdownViews.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct ListItemView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var paragraphSpacing: CGFloat { (10 / 17) * dynamicTypeSize.bodyFontSize }

    let listItemBlock: ListItemBlock
    var children: some View {
        VStack(alignment: .leading, spacing: paragraphSpacing) { // TODO: not using LazyVStack because it cannot be aligned by .firstTextBaseline with list bullet
            ForEach(listItemBlock.children, id: \.id) { child in
                renderMarkdownBlock(child)
            }
        }
    }
    
    var body: some View {
        children
    }
}
