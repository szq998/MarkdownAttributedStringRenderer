//
//  TableView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct TableView: View {
    let tableBlock: TableBlock
    @StateObject var tableGeometryContext: TableGeometryContext
    
    init(tableBlock: TableBlock) {
        self.tableBlock = tableBlock
        _tableGeometryContext = .init(wrappedValue: TableGeometryContext(
            rowCount: tableBlock.rowCount, columnCount: tableBlock.columnCount,
            tableColumnAlignments: tableBlock.tableColumnAlignments,
            cellID2CellPosition: tableBlock.cellID2CellPosition)
        )
    }
    
    var children: some View {
        VStack(alignment: .leading) {
            ForEach(tableBlock.tableRows, id: \.id) { tableRow in
                TableRowView(tableRowBlock: tableRow)
            }
        }
    }
    
    var body: some View {
        children
            .environmentObject(tableGeometryContext)
    }
}

