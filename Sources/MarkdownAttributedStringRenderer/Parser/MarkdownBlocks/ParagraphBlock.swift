//
//  ParagraphBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct ParagraphBlock: MarkdownBlock {
    let transformedAttrStr: AttributedString
    let id: AnyHashable
    
    init(attrStr: AttributedString, id: AnyHashable) {
        self.id = id
        var transformingAttrStr = attrStr
        replaceInlineLineBreakIntentWithNewLineChar(&transformingAttrStr)
        transformedAttrStr = transformingAttrStr
    }
}
