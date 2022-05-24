//
//  ListView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct ListView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var listItemSpacing: CGFloat { (10 / 17) * dynamicTypeSize.bodyFontSize }
    
    let listBlock: ListBlock
    var children: some View {
        VStack(alignment: .leading, spacing: listItemSpacing) {
            ForEach(Array(listBlock.listItems.enumerated()), id: \.1.id) { (idx, item) in
                let ordinal = idx + 1
                ListItemView(listItemBlock: item)
                    .makeListItem(with: listBlock.getListItemDecorator(for: ordinal))
            }
        }
    }
    
    var body: some View {
        children
    }
}
