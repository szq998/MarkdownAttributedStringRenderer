//
//  TableRowView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct TableRowView: View {
    let tableRowBlock: TableRowBlock
    
    var children: some View {
        HStack(spacing: 0) {
            ForEach(tableRowBlock.tableCells, id: \.id) { tableCell in
                TableCellView(tableCellBlock: tableCell)
            }
        }
    }
    
    var body: some View {
        children
            .font(.body.weight(tableRowBlock.isHeaderRow ? .medium : .regular))
    }
}

