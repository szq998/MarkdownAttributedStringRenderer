//
//  MarkdownBlockModifiers.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

struct MakeListItem: ViewModifier {
    let decorator: ListItemDecorator
    let decoratorWidth: CGFloat = 25
    let spaceBetweenSeparatorAndItem: CGFloat = 8
    
    func body(content: Content) -> some View {
        // Use ZStack instead of HStack for performance. Deeply nested HStack have significant impact on responsiveness
        ZStack(alignment: .init(horizontal: .leading, vertical: .firstTextBaseline)) {
            ListItemDecoratorView(decorator: decorator, decoratorWidth: decoratorWidth)
            content
                .padding(.leading, decoratorWidth + spaceBetweenSeparatorAndItem)
        }
    }
}

struct MakeDividerBelow: ViewModifier {
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content
            Divider()
                .padding(.bottom, 10)
        }
    }
}

struct MakeBlockquote: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .light
        ? Color(.displayP3, red: 0.95, green: 0.95, blue: 0.95)
        : Color(.displayP3, red: 0.2, green: 0.2, blue: 0.2)
    }
    
    let isOutermost: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.leading, 4)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .background(
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
            .opacity(isOutermost ? 0.6 : 1)
            .padding([.top, .bottom], 5)
    }
}

struct MakeCodeBlock: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .light
        ? Color(.displayP3, red: 0.95, green: 0.95, blue: 0.95)
        : Color(.displayP3, red: 0.25, green: 0.25, blue: 0.25)
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .bottom], 15)
            .padding([.leading, .trailing], 20)
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(lineWidth: 0.5)
                    .foregroundColor(.secondary)
            )
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(backgroundColor)
            )
            .padding([.top, .bottom], 5)
    }
}

extension View {
    func makeListItem(with decorator: ListItemDecorator) -> some View {
        modifier(MakeListItem(decorator: decorator))
    }
    
    func makeDividerBelow() -> some View {
        modifier(MakeDividerBelow())
    }
    
    func makeBlockquote(isOutermost: Bool) -> some View {
        modifier(MakeBlockquote(isOutermost: isOutermost))
    }
    
    func makeCodeBlock() -> some View {
        modifier(MakeCodeBlock())
    }
}
