//
//  ParagraphBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct ParagraphBlock: MarkdownBlock {
    var id: AnyHashable = 0
    let digest: AnyHashable
    
    let transformedAttrStr: AttributedString
    
    init(digest: AnyHashable, attrStr: AttributedString) {
        self.digest = digest
        var transformingAttrStr = attrStr
        replaceInlineLineBreakIntentWithNewLineChar(&transformingAttrStr)
        transformedAttrStr = transformingAttrStr
    }
}
