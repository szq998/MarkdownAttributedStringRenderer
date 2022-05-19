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
            ForEach(listBlock.listItems, id: \.id) { item in
                ListItemView(listItemBlock: item)
                    .makeListItem(with: listBlock.getListItemDecorator(for: item.ordinal))
            }
        }
    }
    
    var body: some View {
        children
    }
}
