//
//  Document.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

struct Document: ContainerMarkdownBlock {
    let id: AnyHashable
    
    var children: Children
}
