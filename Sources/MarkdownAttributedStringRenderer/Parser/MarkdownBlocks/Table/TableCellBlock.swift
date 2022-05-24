//
//  TableCellBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct TableCellBlock: MarkdownBlock {
    var id: AnyHashable = 0
    let digest: AnyHashable
    
    let attrStr: AttributedString
}
