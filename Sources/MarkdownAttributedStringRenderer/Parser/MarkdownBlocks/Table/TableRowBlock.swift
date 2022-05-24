//
//  TableRowBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct TableRowBlock: ContainerMarkdownBlock {
    var id: AnyHashable = 0
    let digest: AnyHashable
    
    init(digest: AnyHashable, tableCells: [TableCellBlock]) {
        self.digest = digest
        self.children = tableCells
        setChildrenID()
    }
    
    var children: Children
    mutating func setChildrenID() {
        setMarkdownBlockChildrenID(for: &self)
    }
    
    var tableCells: [TableCellBlock] {
        children as! [TableCellBlock]
    }
}
