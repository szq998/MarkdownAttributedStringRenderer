//
//  MarkdownView.swift
//  
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI
import Combine

class MarkdownModel: ObservableObject {
    @Published var rawMarkdown: String
    @Published var document: Document
    
    init(rawMarkdown: String) {
        _rawMarkdown = .init(initialValue: rawMarkdown)
        let parser = MarkdownAttributedStringParser(rawMarkdown.markdowAttrStr)
        _document = .init(initialValue: parser.parse())
        
        $rawMarkdown
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] rawMarkdown in
                self?.document = MarkdownAttributedStringParser(rawMarkdown.markdowAttrStr).parse()
            }
            .store(in: &canceller)
    }
    
    var canceller: Set<AnyCancellable> = []
}

public struct MarkdownView: View {
    private let rawMarkdown: String
    @StateObject var model: MarkdownModel
    
    public init(_ rawMarkdown: String) {
        self.rawMarkdown = rawMarkdown
        self._model = .init(wrappedValue: MarkdownModel(rawMarkdown: rawMarkdown))
    }
    
    public var body: some View {
        DocumentView(document: model.document)
            .onChange(of: rawMarkdown) { newStr in
                model.rawMarkdown = newStr
            }
    }
}

fileprivate extension String {
    var markdowAttrStr: AttributedString {
        try! AttributedString(markdown: self, options: .init(allowsExtendedAttributes: true, interpretedSyntax: .full, failurePolicy: .returnPartiallyParsedIfPossible, languageCode: nil))
    }
}

struct MarkdownAttributedStringRenderer_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownView("# Header\n- List Item 1\n> blockquote")
    }
}
