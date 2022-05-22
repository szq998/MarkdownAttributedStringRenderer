//
//  TableBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

typealias TableColumnAlignment = PresentationIntent.TableColumn.Alignment

struct TableBlock: ContainerMarkdownBlock {
    let id: AnyHashable
    var children: Children
    let tableColumnAlignments: [TableColumnAlignment]
    let cellID2CellPosition: [AnyHashable : CellPosition]
    
    typealias CellPosition = (row: Int, column: Int)
    
    init(id: AnyHashable, tableColumnAlignments: [TableColumnAlignment], tableRows: [TableRowBlock]) {
        self.id = id
        self.tableColumnAlignments = tableColumnAlignments
        
        // align the table by filling the short rows
        var filledTableRows = tableRows
        filledTableRows.enumerated().forEach { (rowIdx, row) in
            if row.children.count < tableColumnAlignments.count {
                let numOfCellToFill = tableColumnAlignments.count - row.children.count
                filledTableRows[rowIdx].children += [TableCellBlock](repeating: .cellForAlignment, count: numOfCellToFill)
            }
        }
        self.children = filledTableRows
        
        var cellID2CellPosition: [AnyHashable : CellPosition] = [:]
        filledTableRows.enumerated().forEach { (rowIdx, rowBlock) in
            rowBlock.children.enumerated().forEach { (columnIdx, cellBlock) in
                cellID2CellPosition[cellBlock.id] = (rowIdx, columnIdx)
            }
        }
        self.cellID2CellPosition = cellID2CellPosition
    }
    
    var rowCount: Int { tableRows.count }
    var columnCount: Int { tableColumnAlignments.count }
    
    var tableRows: [TableRowBlock] {
        get { children as! [TableRowBlock] }
        set { children = newValue }
    }
}

extension TableCellBlock {
    static var cellForAlignment: Self { .init(attrStr: AttributedString(), id: UUID()) } // TODO: is UUID reasonable
}
