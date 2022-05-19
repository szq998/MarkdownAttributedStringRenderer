//
//  ListItemBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct ListItemBlock: ContainerMarkdownBlock {
    let id: AnyHashable
    var children: Children
    let ordinal: Int
}
