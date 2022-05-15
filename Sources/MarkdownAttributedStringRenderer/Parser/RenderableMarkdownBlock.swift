//
//  RenderableMarkdownBlock.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

/// Remove any characters with "softBreak" or "LineBreak" inline presentation intent and replace those with a single new line character.
/// - Parameter attrStr: The attributedString for replacing.
func replaceInlineLineBreakIntentWithNewLineChar(_ attrStr: inout AttributedString) {
// TODO: ignore softBreak at the end of a block
    for (inlineIntent, range) in attrStr.runs[\.inlinePresentationIntent]
    where inlineIntent == .softBreak
    || inlineIntent == .lineBreak
    {
        attrStr.characters.replaceSubrange(range, with: "\n")
    }
}

struct RenderableMarkdownBlock {
    
    enum ListItemDecorator {
        case unordered(isBlankDecorator: Bool = false, nestingLevel: Int)
        case ordered(isBlankDecorator: Bool = false, nestingLevel: Int, ordinal: Int)
        
        var isBlank: Bool {
            switch self {
            case .ordered(isBlankDecorator: let isBlank, nestingLevel: _, ordinal: _):
                return isBlank
            case .unordered(isBlankDecorator: let isBlank, nestingLevel: _):
                return isBlank
            }
        }
    }
    
    static func thematicBreak(with id: AnyHashable) -> Self { Self(thematicBreakWith: id) }
    
    
    let isThematicBreak: Bool
    
    private var attrStrWithInlineIntentTransformed: AttributedString!
    var attrStr: AttributedString {
        get { attrStrWithInlineIntentTransformed }
        set {
            attrStrWithInlineIntentTransformed = newValue
            replaceInlineLineBreakIntentWithNewLineChar(&attrStrWithInlineIntentTransformed)
        }
    }
    var indentationLevel = 1
    var hasDividerBelow = false // for h1/h2
    var isInBlockquote = false
    var isInCodeBlock = false
    var codeLangHint: String? {
        didSet {
            guard let codeLangHint = codeLangHint else { return }
            isInCodeBlock = true
            // syntax highlight
            // TODO:
        }
    }
    var listItemDecorator: ListItemDecorator?
    
    let id: AnyHashable
    
    private init(thematicBreakWith id: AnyHashable) {
        self.isThematicBreak = true
        self.id = id
    }
    
    init(attrStr: AttributedString, id: AnyHashable,
         indentationLevel: Int = 1
    ) {
        self.id = id
        self.indentationLevel = indentationLevel
        self.isThematicBreak = false
        
        self.attrStr = attrStr
    }
    
    @ViewBuilder
    func render() -> some View {
        if isThematicBreak {
            Divider().padding([.top, .bottom])
        } else {
            Text(attrStr)
                .makeDividerBelow(if: hasDividerBelow)
                .makeCodeBlock(if: isInCodeBlock)
                .makeBlockquote(if: isInBlockquote)
                .makeListItem(ifHas: listItemDecorator)
                .indent(level: indentationLevel)
        }
    }
}
