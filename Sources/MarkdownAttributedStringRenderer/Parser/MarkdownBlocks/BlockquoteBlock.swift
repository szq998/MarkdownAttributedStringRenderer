//
//  BlockquoteBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct BlockquoteBlock: ContainerMarkdownBlock {
    var id: AnyHashable = 0
    let digest: AnyHashable
    
    init(digest: AnyHashable, isOutermost: Bool, children: Children) {
        self.digest = digest
        self.isOutermost = isOutermost
        self.children = children
        setChildrenID()
    }
    
    var isOutermost: Bool
    var children: Children
    mutating func setChildrenID() {
        setMarkdownBlockChildrenID(for: &self)
    }
}
