//
//  ParagraphView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct ParagraphView: View {
    let paragraphBlock: ParagraphBlock
    
    var body: some View {
        Text(paragraphBlock.transformedAttrStr)
    }
}
