//
//  MarkdownAttributedStringView.swift
//  
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

public struct MarkdownAttributedStringView: View {
    public init(_ markdownStr: String) {
        self.markdownStr = markdownStr
    }
    
    private let markdownStr: String
    public var body: some View {
        MarkdownAttributedStringParser(markdownStr.markdowAttrStr)
            .parse()
            .rendered
    }
}

fileprivate extension String {
    var markdowAttrStr: AttributedString {
        try! AttributedString(markdown: self, options: .init(allowsExtendedAttributes: true, interpretedSyntax: .full, failurePolicy: .returnPartiallyParsedIfPossible, languageCode: nil))
    }
}

struct MarkdownAttributedStringRenderer_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownAttributedStringView("# Header\n- List Item 1\n> blockquote")
    }
}
