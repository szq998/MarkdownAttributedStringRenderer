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
        self.children = tableRows
        
        
        var cellID2CellPosition: [AnyHashable : CellPosition] = [:]
        tableRows.enumerated().forEach { (rowIdx, rowBlock) in
            rowBlock.children.enumerated().forEach { (columnIdx, cellBlock) in
                cellID2CellPosition[cellBlock.id] = (rowIdx, columnIdx)
            }
        }
        self.cellID2CellPosition = cellID2CellPosition
    }
    
    var rowCount: Int { tableRows.count }
    var columnCount: Int { tableColumnAlignments.count }
    
    var tableRows: [TableRowBlock] {
        children as! [TableRowBlock]
    }
}
