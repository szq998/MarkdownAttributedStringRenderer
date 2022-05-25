//
//  MarkdownView.swift
//  
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI
import Combine

extension Document {
    static let blank = Document(digest: 0, children: [])
}

@MainActor
class MarkdownModel: ObservableObject {
    @Published public var rawMarkdown: String
    @Published private(set) var document: Document = .blank
    
    init(rawMarkdown: String) {
        _rawMarkdown = .init(initialValue: rawMarkdown)
        Task {
            await self.parseRawMarkdown()
        }
        
        $rawMarkdown
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] rawMarkdown in
                guard let self = self else { return }
                Task {
                    await self.parseRawMarkdown()
                }
            }
            .store(in: &canceller)
    }
    
    private func parseRawMarkdown() async {
        document = await parser.parse(rawMarkdown.markdowAttrStr)
    }
    
    private let parser = MarkdownAttributedStringParser()
    private var canceller: Set<AnyCancellable> = []
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
        (try? AttributedString(markdown: self, options: .init(allowsExtendedAttributes: true, interpretedSyntax: .full, failurePolicy: .returnPartiallyParsedIfPossible, languageCode: nil)))
        ?? AttributedString(self)
    }
}

struct MarkdownAttributedStringRenderer_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownView("# Header\n- List Item 1\n> blockquote")
    }
}
