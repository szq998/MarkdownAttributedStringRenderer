//
//  ListView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct ListView: View {
    let listBlock: ListBlock
    
    var children: some View {
        VStack(alignment: .leading, spacing: 5) {
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
