//
//  CodeBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct CodeBlock: MarkdownBlock {
    var id: AnyHashable = 0
    let digest: AnyHashable
    
    let transformedAttrStr: AttributedString
    
    init(digest: AnyHashable, attrStr: AttributedString, conLangHint: String?) {
        self.digest = digest
        var transformingAttrStr = attrStr
        if let lastChar = transformingAttrStr.characters.last, lastChar == "\n" {
            transformingAttrStr.characters.removeLast()
        }
        // TODO: syntax highlight
        transformedAttrStr = transformingAttrStr
    }
}
