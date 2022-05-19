//
//  CodeView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct CodeView: View {
    let codeBlock: CodeBlock
    
    var body: some View {
        Text(codeBlock.transformedAttrStr)
            .makeCodeBlock()
    }
}
