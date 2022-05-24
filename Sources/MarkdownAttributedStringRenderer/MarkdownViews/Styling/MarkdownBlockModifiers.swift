//
//  MarkdownBlockModifiers.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

struct MakeListItem: ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var decoratorWidth: CGFloat { (25 / 17) * dynamicTypeSize.bodyFontSize }
    var spaceBetweenSeparatorAndItem: CGFloat { (8 / 17) * dynamicTypeSize.bodyFontSize }
    
    let decorator: ListItemDecorator
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
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var spacingBetween: CGFloat { (10 / 17) * dynamicTypeSize.bodyFontSize }
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: spacingBetween) {
            content
            Divider()
        }
    }
}

struct MakeBlockquote: ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var decorationBarWidth: CGFloat { (4 / 17) * dynamicTypeSize.bodyFontSize }
    var textInset: CGFloat { (10 / 17) * dynamicTypeSize.bodyFontSize }
    var extraVerticalMargin: CGFloat { (5 / 17) * dynamicTypeSize.bodyFontSize }
    
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color {
        colorScheme == .light
        ? Color(.displayP3, red: 0.95, green: 0.95, blue: 0.95)
        : Color(.displayP3, red: 0.2, green: 0.2, blue: 0.2)
    }
    
    let isOutermost: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.leading, decorationBarWidth)
            .padding(textInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: decorationBarWidth)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
            .background(backgroundColor)
            .opacity(isOutermost ? 0.6 : 1)
            .padding([.top, .bottom], extraVerticalMargin)
    }
}

struct MakeCodeBlock: ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var textVerticalInset: CGFloat { (15 / 17) * dynamicTypeSize.bodyFontSize }
    var textHorizontalInset: CGFloat { (20 / 17) * dynamicTypeSize.bodyFontSize }
    var extraVerticalMargin: CGFloat { (5 / 17) * dynamicTypeSize.bodyFontSize }
    
    var borderWidth: CGFloat { max(0.5, (0.5 / 17) * dynamicTypeSize.bodyFontSize) }
    var cornerRadius: CGFloat { (5 / 17) * dynamicTypeSize.bodyFontSize }
    
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color {
        colorScheme == .light
        ? Color(.displayP3, red: 0.95, green: 0.95, blue: 0.95)
        : Color(.displayP3, red: 0.25, green: 0.25, blue: 0.25)
    }
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .bottom], textVerticalInset)
            .padding([.leading, .trailing], textHorizontalInset)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(lineWidth: borderWidth)
                    .foregroundColor(.secondary)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .foregroundColor(backgroundColor)
            )
            .padding([.top, .bottom], extraVerticalMargin)
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
