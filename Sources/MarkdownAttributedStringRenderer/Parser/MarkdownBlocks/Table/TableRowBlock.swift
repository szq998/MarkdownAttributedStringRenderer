//
//  TableRowBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct TableRowBlock: ContainerMarkdownBlock {
    let id: AnyHashable
    let isHeaderRow: Bool
    var children: Children
    
    init(id: AnyHashable, isHeaderRow: Bool, tableCells: [TableCellBlock]) {
        self.id = id
        self.isHeaderRow = isHeaderRow
        self.children = tableCells
    }
    
    var tableCells: [TableCellBlock] {
        children as! [TableCellBlock]
    }
}
