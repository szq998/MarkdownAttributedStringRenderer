//
//  ListBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct ListBlock: ContainerMarkdownBlock {
    let id: AnyHashable
    let isOrdered: Bool
    let nestingLevel: Int
    
    init(id: AnyHashable, isOrdered: Bool, nestingLevel: Int, listItems: [ListItemBlock]) {
        self.id = id
        self.isOrdered = isOrdered
        self.nestingLevel = nestingLevel
        self.children = listItems
    }
    
    var children: Children
    var listItems: [ListItemBlock] {
        children as! [ListItemBlock]
    }
    
    func getListItemDecorator(for ordinal: Int) -> ListItemDecorator {
        isOrdered
        ? .ordered(nestingLevel: nestingLevel, ordinal: ordinal)
        : .unordered(nestingLevel: nestingLevel)
    }
}
