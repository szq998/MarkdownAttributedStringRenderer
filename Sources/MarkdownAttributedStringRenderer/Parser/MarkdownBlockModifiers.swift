//
//  MarkdownBlockModifiers.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

struct Indentation: ViewModifier {
    let indentationLevel: Int
    func body(content: Content) -> some View {
        content.padding(.leading, 15 * CGFloat(indentationLevel))
    }
}


struct MakeListItem: ViewModifier {
    let decorator: RenderableMarkdownBlock.ListItemDecorator
    
    func body(content: Content) -> some View {
        HStack(alignment: .firstTextBaseline) {
            ListItemDecoratorView(decorator: decorator)
            content
        }
    }
}

struct MakeDividerBelow: ViewModifier {
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            Divider()
                .padding(.bottom)
        }
    }
}

struct MakeBlockquote: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 15) {
            Rectangle()
                .frame(width: 3)
            content
        }
        .opacity(0.7)
    }
}

struct MakeCodeBlock: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .foregroundColor(Color(.displayP3, red: 0.8, green: 0.8, blue: 0.8))
            )
            .padding(.bottom, 2)
    }
}

extension View {
    func indent(level: Int) -> some View {
        modifier(Indentation(indentationLevel: level))
    }
    
    func makeListItem(with decorator: RenderableMarkdownBlock.ListItemDecorator) -> some View {
        modifier(MakeListItem(decorator: decorator))
    }
    
    @ViewBuilder
    func makeListItem(ifHas decorator: RenderableMarkdownBlock.ListItemDecorator?) -> some View {
        if let decorator = decorator {
            modifier(MakeListItem(decorator: decorator))
        } else {
            self
        }
    }
    
    func makeDividerBelow() -> some View {
        modifier(MakeDividerBelow())
    }
    
    @ViewBuilder
    func makeDividerBelow(if hasDividerBelow: Bool) -> some View {
        if !hasDividerBelow {
            self
        } else {
            modifier(MakeDividerBelow())
        }
    }
    
    func makeBlockquote() -> some View {
        modifier(MakeBlockquote())
    }
    
    @ViewBuilder
    func makeBlockquote(if isInBlockquote: Bool) -> some View {
        if !isInBlockquote {
            self
        } else {
            modifier(MakeBlockquote())
        }
    }
    
    func makeCodeBlock() -> some View {
        modifier(MakeCodeBlock())
    }
    
    @ViewBuilder
    func makeCodeBlock(if isInCodeBlock: Bool) -> some View {
        if !isInCodeBlock {
            self
        } else {
            modifier(MakeCodeBlock())
        }
     }
}

