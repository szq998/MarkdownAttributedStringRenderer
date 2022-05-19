//
//  TableGeometryContext.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

extension TableColumnAlignment {
    func viewAlignment(for layoutDirection: LayoutDirection) -> Alignment {
        switch self {
        case .left:
            return layoutDirection == .leftToRight ? .leading : .trailing
        case .center:
            return .center
        case .right:
            return layoutDirection == .leftToRight ? .trailing : .leading
        @unknown default:
            return .center
        }
    }
}

class TableGeometryContext: ObservableObject {
    let rowCount: Int
    let columnCount: Int
    let tableColumnAlignments: [TableColumnAlignment]
    
    typealias CellPosition = (row: Int, column: Int)
    
    let cellID2CellPosition: [AnyHashable : CellPosition]
    
    init(rowCount: Int, columnCount: Int, tableColumnAlignments: [TableColumnAlignment], cellID2CellPosition: [AnyHashable : CellPosition]) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.tableColumnAlignments = tableColumnAlignments
        self.cellID2CellPosition = cellID2CellPosition
        
        rowHeights = [CGFloat?](repeating: nil, count: rowCount)
        columnWidths = [CGFloat?](repeating: nil, count: columnCount)
    }
    
    @Published var rowHeights: [CGFloat?]
    @Published var columnWidths: [CGFloat?]
    
    func update(cellSize: CGSize, for id: AnyHashable) {
        assert(cellID2CellPosition.keys.contains(id))
        guard let position = cellID2CellPosition[id] else { return }
        
        rowHeights[position.row] = max(rowHeights[position.row] ?? 0, cellSize.height)
        columnWidths[position.column] = max(columnWidths[position.column] ?? 0, cellSize.width)
    }
    
    func width(for cellID: AnyHashable) -> CGFloat? {
        assert(cellID2CellPosition.keys.contains(cellID))
        guard let column = cellID2CellPosition[cellID]?.column else { return nil }
        return columnWidths[column]
    }
    
    func height(for cellID: AnyHashable) -> CGFloat? {
        assert(cellID2CellPosition.keys.contains(cellID))
        guard let row = cellID2CellPosition[cellID]?.row else { return nil }
        return rowHeights[row]
    }
    
    func alignment(for cellID: AnyHashable) -> TableColumnAlignment {
        assert(cellID2CellPosition.keys.contains(cellID))
        guard let column = cellID2CellPosition[cellID]?.column else { return .center }
        return tableColumnAlignments[column]
    }
}
