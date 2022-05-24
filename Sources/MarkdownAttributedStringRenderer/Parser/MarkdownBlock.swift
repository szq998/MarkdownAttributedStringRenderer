//
//  RenderableMarkdownBlock.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

protocol ContainerMarkdownBlock: MarkdownBlock {
    typealias Children = [MarkdownBlock]
    var children: Children { get set }
    
    /// Generate and set unique IDs for children within the block.
    mutating func setChildrenID()
}

protocol MarkdownBlock {
    var id: AnyHashable { get set }
    var digest: AnyHashable { get }
}

func setMarkdownBlockChildrenID<Container>(for container: inout Container) where Container: ContainerMarkdownBlock {
    var childIDSet: Set<AnyHashable> = []
    var duplicatedIDCount: [AnyHashable : Int] = [:]
    
    for idx in container.children.indices {
        var id = container.children[idx].digest
        if childIDSet.contains(id) {
            // record duplicate ID count
            let count = duplicatedIDCount[id] ?? 1
            duplicatedIDCount[id] = count + 1
            
            var hasher = Hasher()
            hasher.combine(id)
            hasher.combine(count)
            id = hasher.finalize()
        }
        childIDSet.insert(id)
        container.children[idx].id = id
    }
}

