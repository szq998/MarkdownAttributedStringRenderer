//
//  CodeBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct CodeBlock: MarkdownBlock {
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
}
