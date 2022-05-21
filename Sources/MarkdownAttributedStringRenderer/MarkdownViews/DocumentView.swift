//
//  DocumentView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct DocumentView: View {
    let document: Document
    
    var children: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(document.children, id: \.id) { child in
                renderMarkdownBlock(child)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        children
    }
}
