//
//  TableLayoutContext.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI
import Combine

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

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

fileprivate extension Array where Element == Array<CGSize> {
    subscript(position: TableLayoutContext.CellPosition) -> CGSize {
        get { self[position.row][position.column] }
        set { self[position.row][position.column] = newValue }
    }
}

class TableLayoutContext: ObservableObject {
    let rowCount: Int
    let columnCount: Int
    let tableColumnAlignments: [TableColumnAlignment]
    
    typealias CellPosition = (row: Int, column: Int)
    let cellID2CellPosition: [AnyHashable : CellPosition]
    
    let containerWidthSubject = PassthroughSubject<CGFloat, Never>()
    var cancellers: Set<AnyCancellable> = []
    
    init(rowCount: Int, columnCount: Int, tableColumnAlignments: [TableColumnAlignment], cellID2CellPosition: [AnyHashable : CellPosition]) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.tableColumnAlignments = tableColumnAlignments
        self.cellID2CellPosition = cellID2CellPosition
        
        cellSizes = [[CGSize]](repeating: [CGSize](repeating: .zero, count: columnCount), count: rowCount)
        
        containerWidthSubject
            .removeDuplicates()
            .sink { [weak self] _ in
                // invalidate column width when ccontainer size changed
                withAnimation {
                    self?.isColumnWidthValid = false
                }
            }
            .store(in: &cancellers)
        
        containerWidthSubject
            .removeDuplicates()
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] newWidth in
                guard let self = self else { return }
                
                withAnimation {
                    let columnWidthSum = self.columnWidths.reduce(CGFloat.zero) { partialResult, width in
                        if let width = width {
                            return partialResult + width
                        } else {
                            return partialResult
                        }
                    }
                    
                    if columnWidthSum > newWidth {
                        self.columnWidths = [CGFloat?](repeating: newWidth / CGFloat(columnCount), count: columnCount)
                    }
                    
                    self.isColumnWidthValid = true
                }
                //                print("Column width reset to \(newWidth)")
            }
            .store(in: &self.cancellers)
    }
    
    @Published var isColumnWidthValid: Bool = false
    @Published var cellSizes: [[CGSize]]
    
    var columnWidths: [CGFloat?] {
        get {
            (0..<columnCount).map { column in
                width(at: column)
            }
        }
        set {
            (0..<rowCount).forEach { row in
                (0..<columnCount).forEach { column in
                    cellSizes[(row, column)].width = newValue[column] ?? .zero
                }
            }
        }
    }
    
    var rowHeights: [CGFloat?] {
        (0..<rowCount).map { row in
            height(at: row)
        }
    }
    
    func width(at column: Int) -> CGFloat? {
        let width = cellSizes.reduce(CGFloat.zero) { partialResult, row in
            max(partialResult, row[column].width)
        }
        return width == .zero ? nil : width
    }
    
    func height(at row: Int) -> CGFloat? {
        let height = cellSizes[row].reduce(CGFloat.zero) { partialResult, cellSize in
            max(partialResult, cellSize.height)
        }
        return height == .zero ? nil : height
    }
    
    var hasAllSizeAcquired: Bool {
        cellSizes.allSatisfy { row in
            row.allSatisfy { size in
                size.width != .zero && size.height != .zero
            }
        }
    }
    
    func update(containerWidth: CGFloat) {
        //        print("Container width changed to \(containerWidth)")
        containerWidthSubject.send(containerWidth)
    }
    
    func update(cellSize: CGSize, for id: AnyHashable) {
        assert(cellID2CellPosition.keys.contains(id))
        guard let position = cellID2CellPosition[id] else { return }
        
        cellSizes[position] = cellSize
        //        print("Cell at \(position) reported size of \(cellSize)")
    }
    
    func width(for cellID: AnyHashable) -> CGFloat? {
        guard isColumnWidthValid else { return nil }
        
        assert(cellID2CellPosition.keys.contains(cellID))
        guard let column = cellID2CellPosition[cellID]?.column, let width = width(at: column) else { return nil }
        return width
    }
    
    func alignment(for cellID: AnyHashable) -> TableColumnAlignment {
        assert(cellID2CellPosition.keys.contains(cellID))
        guard let column = cellID2CellPosition[cellID]?.column else { return .center }
        return tableColumnAlignments[column]
    }
}

