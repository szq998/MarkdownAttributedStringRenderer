//
//  TableView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct TableView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
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
            ForEach(Array(tableBlock.tableRows.enumerated()), id: \.1.id) { (idx, tableRow) in
                TableRowView(tableRowBlock: tableRow)
                    .font(.body.weight(idx == 0 ? .semibold : .regular)) // first row is the table header
            }
        }
    }
    
    var body: some View {
        HStack { // children nesting in another container to prevent always consuming all horizontal space
            children
                .drawTableSeparator()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onSizeChange(perform: { size in
            guard size.width != .zero else { return }
            tableLayoutContext.update(containerWidth: size.width)
        })
        .onChange(of: dynamicTypeSize, perform: { _ in
            tableLayoutContext.requestRelayout()
        })
        .environmentObject(tableLayoutContext)
    }
}

