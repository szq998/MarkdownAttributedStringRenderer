//
//  TableBlock.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

typealias TableColumnAlignment = PresentationIntent.TableColumn.Alignment

struct TableBlock: ContainerMarkdownBlock {
    var id: AnyHashable = 0
    let digest: AnyHashable
    
    var children: Children
    mutating func setChildrenID() {
        setMarkdownBlockChildrenID(for: &self)
    }
    /// `setChildrenID()` only ensure table rows' IDs are unique in the table, while this method ensure table cells' IDs are unique in the table
    mutating func setTableCellID() {
        var cellIDs: Set<AnyHashable> = []
        for rowIdx in tableRows.indices {
            for columnIdx in tableRows[rowIdx].children.indices {
                var id = tableRows[rowIdx].children[columnIdx].id
                if cellIDs.contains(id) {
                    var hasher = Hasher()
                    hasher.combine(id)
                    hasher.combine(rowIdx)
                    hasher.combine(columnIdx)
                    id = hasher.finalize()
                    tableRows[rowIdx].children[columnIdx].id = id
                }
                cellIDs.insert(id)
            }
        }
    }
    
    let tableColumnAlignments: [TableColumnAlignment]
    var cellID2CellPosition: [AnyHashable : CellPosition] = [:]
    
    typealias CellPosition = (row: Int, column: Int)
    
    init(digest: AnyHashable, tableColumnAlignments: [TableColumnAlignment], tableRows: [TableRowBlock]) {
        self.digest = digest
        self.tableColumnAlignments = tableColumnAlignments
        
        // align the table by filling the short rows
        var filledTableRows = tableRows
        filledTableRows.enumerated().forEach { (rowIdx, row) in
            if row.children.count < tableColumnAlignments.count {
                let filledCellCount = tableColumnAlignments.count - row.children.count
                filledTableRows[rowIdx].children += [TableCellBlock](repeating: .cellForAlignment, count: filledCellCount)
                filledTableRows[rowIdx].setChildrenID()
            }
        }
        self.children = filledTableRows
        setChildrenID()
        setTableCellID()
        
        self.tableRows.enumerated().forEach { (rowIdx, rowBlock) in
            rowBlock.children.enumerated().forEach { (columnIdx, cellBlock) in
                cellID2CellPosition[cellBlock.id] = (rowIdx, columnIdx)
            }
        }
    }
    
    var rowCount: Int { tableRows.count }
    var columnCount: Int { tableColumnAlignments.count }
    
    var tableRows: [TableRowBlock] {
        get { children as! [TableRowBlock] }
        set { children = newValue }
    }
}

extension TableCellBlock {
    static var cellForAlignment: Self { Self(digest: 0 /* dummy digest */, attrStr: AttributedString()) }
}
