//
//  ListItemDecoratorView.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

enum ListItemDecorator {
    case unordered(nestingLevel: Int)
    case ordered(nestingLevel: Int, ordinal: Int)
}

struct ListItemDecoratorView: View {
    let decorator: ListItemDecorator
    let decoratorWidth: CGFloat
    
    var body: some View {
        Group {
            switch decorator {
            case .unordered(nestingLevel: let level):
                switch level - 1 {
                case 0:
                    Text("•") // bullet
                        .font(.body.weight(.black))
                case 1:
                    Text("◦") // white bullet
                        .font(.body.weight(.black))
                case 2:
                    Text("▪︎") // small square
                default:
                    Text("▫︎") // white small square
                }
            case .ordered(nestingLevel: _, ordinal: let ordinal):
                Text("\(ordinal).")
                    .font(.subheadline.monospacedDigit().weight(.light))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }
        }
        .frame(width: decoratorWidth, alignment: .trailing)
    }
}
