//
//  Document.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct Document: ContainerMarkdownBlock {
    var id: AnyHashable = 0 // document's ID is actually not useful, because document will always at top level
    let digest: AnyHashable
    
    init(digest: AnyHashable, children: Children) {
        self.digest = digest
        self.children = children
        setChildrenID()
    }
    
    var children: Children
    mutating func setChildrenID() {
        setMarkdownBlockChildrenID(for: &self)
    }
}
