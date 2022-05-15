//
//  MarkdownAttributedStringRenderer.swift
//  
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

struct MarkdownAttributedStringRenderer: View {
    let markdownStr: String
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(markdownStr.renderableMarkdownBlocks, id: \.id) { $0.render() }
        }
    }
}

fileprivate extension String {
    var renderableMarkdownBlocks: [RenderableMarkdownBlock] {
        let attrStr = try! AttributedString(markdown: self, options: .init(allowsExtendedAttributes: true, interpretedSyntax: .full, failurePolicy: .returnPartiallyParsedIfPossible, languageCode: nil))
        
        return MarkdownAttributedStringParser.shared.parse(attrStr)
    }
}

struct MarkdownAttributedStringRenderer_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownAttributedStringRenderer(markdownStr: "# Header\n- List Item 1\n> blockquote")
    }
}
