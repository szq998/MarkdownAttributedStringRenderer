//
//  HeaderBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct HeaderBlock: MarkdownBlock {
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
}
