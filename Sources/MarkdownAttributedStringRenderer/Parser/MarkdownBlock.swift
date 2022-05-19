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
}

protocol MarkdownBlock {
    var id: AnyHashable { get }
}
