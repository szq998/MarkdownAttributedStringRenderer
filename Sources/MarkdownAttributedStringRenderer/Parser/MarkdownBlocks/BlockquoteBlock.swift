//
//  BlockquoteBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct BlockquoteBlock: ContainerMarkdownBlock {
    let id: AnyHashable
    let isOutermost: Bool
    var children: Children
}
