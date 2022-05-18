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
    for (inlineIntent, range) in attrStr.runs[\.inlinePresentationIntent]
    where (inlineIntent == .softBreak && range.lowerBound != attrStr.endIndex) // ignore softBreak at the end of a block
    || inlineIntent == .lineBreak
    {
        attrStr.characters.replaceSubrange(range, with: "\n")
    }
}

struct ThematicBreakBlock: RenderableBlock {
    
    let id: AnyHashable
    
    var rendered: AnyView { AnyView(_rendered) }
    private var _rendered: some View {
        Divider()
    }
}

struct ParagraphBlock: RenderableBlock {
    
    let transformedAttrStr: AttributedString
    let id: AnyHashable
    
    init(attrStr: AttributedString, id: AnyHashable) {
        self.id = id
        var transformingAttrStr = attrStr
        replaceInlineLineBreakIntentWithNewLineChar(&transformingAttrStr)
        transformedAttrStr = transformingAttrStr
    }
    
    var rendered: AnyView { AnyView(_rendered) }
    private var _rendered: some View {
        Text(transformedAttrStr)
    }
}

struct HeaderBlock: RenderableBlock {
    
    let id: AnyHashable
    
    let transformedAttrStr: AttributedString
    let hasDividerBelow: Bool
    
    init(attrStr: AttributedString, id: AnyHashable, headerLevel: Int) {
        self.id = id
        self.hasDividerBelow = headerLevel < 3
        let transformedFont = headerLevel == 1
        ? Font.largeTitle.weight(.semibold)
        : headerLevel  == 2
        ? Font.title.weight(.semibold)
        : headerLevel == 3
        ? Font.title2.weight(.semibold)
        : headerLevel == 4
        ? Font.title3.weight(.semibold)
        : headerLevel == 5
        ? Font.custom("Header Level 5", size: 20, relativeTo: .title3).weight(.heavy)
        : Font.custom("Header Level 6", size: 18, relativeTo: .title3).weight(.heavy)
        
        var transformingAttrStr = attrStr.transformingAttributes(\.presentationIntent) { transformer in
            transformer.replace(with: \.font, value: transformedFont)
        }
        replaceInlineLineBreakIntentWithNewLineChar(&transformingAttrStr)
        transformedAttrStr = transformingAttrStr
    }
    
    var rendered: AnyView { AnyView(_rendered) }
    @ViewBuilder
    private var _rendered: some View {
        let header = Text(transformedAttrStr)
        if hasDividerBelow {
            header
                .makeDividerBelow()
        } else {
            header
        }
    }
}

struct CodeBlock: RenderableBlock {
    
    let id: AnyHashable
    let transformedAttrStr: AttributedString
    
    init(attrStr: AttributedString, id: AnyHashable, conLangHint: String?) {
        self.id = id
        var transformingAttrStr = attrStr
        if let lastChar = transformingAttrStr.characters.last, lastChar == "\n" {
            transformingAttrStr.characters.removeLast()
        }
        // TODO: syntax highlight
        transformedAttrStr = transformingAttrStr
    }
    
    var rendered: AnyView { AnyView(_rendered) }
    private var _rendered: some View {
        Text(transformedAttrStr)
            .makeCodeBlock()
    }
}

struct BlockquoteBlock: ContainerRenderableBlock {
    
    let id: AnyHashable
    let isOutermost: Bool
    
    var children: Children
    
    var renderedChildren: AnyView { AnyView(_renderedChildren) }
    private var _renderedChildren: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(children, id: \.id) { child in
                child.rendered
            }
        }
    }
    
    var rendered: AnyView { AnyView(_rendered) }
    private var _rendered: some View {
        _renderedChildren
            .makeBlockquote(isOutermost: isOutermost)
    }
}

struct ListBlock: ContainerRenderableBlock {
    let id: AnyHashable
    let isOrdered: Bool
    let nestingLevel: Int
    
    init(id: AnyHashable, isOrdered: Bool, nestingLevel: Int, listItems: [ListItemBlock]) {
        self.id = id
        self.isOrdered = isOrdered
        self.nestingLevel = nestingLevel
        self.children = listItems
    }
    
    var children: Children
    var listItems: [ListItemBlock] {
        children as! [ListItemBlock]
    }
    
    func getListItemDecorator(for ordinal: Int) -> ListItemDecorator {
        isOrdered
        ? .ordered(nestingLevel: nestingLevel, ordinal: ordinal)
        : .unordered(nestingLevel: nestingLevel)
    }
    
    var renderedChildren: AnyView { AnyView(_renderedChildren) }
    private var _renderedChildren: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(listItems, id: \.id) { item in
                item.rendered
                    .makeListItem(with: getListItemDecorator(for: item.ordinal))
            }
        }
    }
    var rendered: AnyView { AnyView(_rendered) }
    private var _rendered: some View {
        _renderedChildren
    }
}

struct ListItemBlock: ContainerRenderableBlock {
    let id: AnyHashable
    
    var children: Children
    
    let ordinal: Int
    
    var renderedChildren: AnyView { AnyView(_renderedChildren) }
    private var _renderedChildren: some View {
        VStack(alignment: .leading, spacing: 5) { // TODO: not using LazyVStack because it cannot be aligned by .firstTextBaseline with list bullet
            ForEach(children, id: \.id) { child in
                child.rendered
            }
        }
    }
    
    var rendered: AnyView { AnyView(_rendered) }
    private var _rendered: some View {
        _renderedChildren
    }
}

struct Document: ContainerRenderableBlock {
    let id: AnyHashable
    
    var children: Children
    var renderedChildren: AnyView {
        AnyView(_renderedChildren)
    }
    private var _renderedChildren: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            ForEach(children, id: \.id) { child in
                child.rendered
            }
        }
    }
    var rendered: AnyView {
        AnyView(_rendered)
    }
    private var _rendered: some View {
        _renderedChildren
    }
}

protocol ContainerRenderableBlock: RenderableBlock {
    typealias Children = [RenderableBlock]
    var children: Children { get set }
    
    @ViewBuilder
    var renderedChildren: AnyView { get }
}


protocol RenderableBlock {
    var id: AnyHashable { get }
    
    var rendered: AnyView { get }
}

