//
//  HeaderView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct HeaderView: View {
    let headerBlock: HeaderBlock
    
    var body: some View {
        let header = Text(headerBlock.transformedAttrStr)
        if headerBlock.hasDividerBelow {
            header
                .makeDividerBelow()
        } else {
            header
        }
    }
}
