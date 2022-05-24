//
//  ListBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct ListBlock: ContainerMarkdownBlock {
    var id: AnyHashable = 0
    let digest: AnyHashable
    
    let isOrdered: Bool
    var nestingLevel: Int
    
    init(digest: AnyHashable, isOrdered: Bool, nestingLevel: Int, listItems: [ListItemBlock]) {
        self.digest = digest
        self.isOrdered = isOrdered
        self.nestingLevel = nestingLevel
        self.children = listItems
        
        setChildrenID()
    }
    
    var children: Children
    var listItems: [ListItemBlock] {
        children as! [ListItemBlock]
    }
    mutating func setChildrenID() {
        setMarkdownBlockChildrenID(for: &self)
    }
    
    func getListItemDecorator(for ordinal: Int) -> ListItemDecorator {
        isOrdered
        ? .ordered(nestingLevel: nestingLevel, ordinal: ordinal)
        : .unordered(nestingLevel: nestingLevel)
    }
}
