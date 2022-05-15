//
//  ListItemDecoratorView.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

struct ListItemDecoratorView: View {
    let decorator: RenderableMarkdownBlock.ListItemDecorator
    
    var body: some View {
        Group {
            if decorator.isBlank {
                Text(" ") // whitespace as placeholder
            } else {
                switch decorator {
                case .unordered(isBlankDecorator: _, nestingLevel: let level):
                    switch level - 1 {
                    case 0:
                        Text("•") // bullet
                    case 1:
                        Text("◦") // white bullet
                    case 2:
                        Text("▪︎") // small square
                    default:
                        Text("▫︎") // white small square
                    }
                case .ordered(isBlankDecorator: _, nestingLevel: _, ordinal: let ordinal):
                    Text("\(ordinal).")
                }
            }
        }
        .frame(width: 15, alignment: .trailing)
    }
}
