//
//  renderMarkdownBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

@ViewBuilder
func renderMarkdownBlock(_ block: MarkdownBlock) -> some View {
    if block is ThematicBreakBlock {
        ThematicBreakView()
    } else if let block = block as? ParagraphBlock {
        ParagraphView(paragraphBlock: block)
    } else if let block = block as? HeaderBlock {
        HeaderView(headerBlock: block)
    } else if let block = block as? CodeBlock {
        CodeView(codeBlock: block)
    } else if let block = block as? BlockquoteBlock {
        BlockquoteView(blockquoteBlock: block)
    } else if let block = block as? ListBlock {
        ListView(listBlock: block)
    } else if let block = block as? TableBlock {
        TableView(tableBlock: block)
    } else if block is ListItemBlock || block is TableCellBlock || block is TableRowBlock {
        fatalError("ListItem, TableCell and TableRow should be handled by their dedicated container")
    } else {
        fatalError()
    }
}
