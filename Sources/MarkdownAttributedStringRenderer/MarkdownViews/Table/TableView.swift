//
//  TableView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct TableView: View {
    let tableBlock: TableBlock
    @StateObject var tableLayoutContext: TableLayoutContext
    
    init(tableBlock: TableBlock) {
        self.tableBlock = tableBlock
        _tableLayoutContext = .init(wrappedValue: TableLayoutContext(
            rowCount: tableBlock.rowCount, columnCount: tableBlock.columnCount,
            tableColumnAlignments: tableBlock.tableColumnAlignments,
            cellID2CellPosition: tableBlock.cellID2CellPosition)
        )
    }
    
    var children: some View {
        VStack(spacing: 0) {
            ForEach(tableBlock.tableRows, id: \.id) { tableRow in
                TableRowView(tableRowBlock: tableRow)
            }
        }
    }
    
    var body: some View {
        HStack {
            children
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onSizeChange(perform: { size in
            guard size.width != .zero else { return }
            tableLayoutContext.update(containerWidth: size.width)
        })
        .drawTableSeparator(tableLayoutContext: tableLayoutContext)
        .environmentObject(tableLayoutContext)
    }
}

