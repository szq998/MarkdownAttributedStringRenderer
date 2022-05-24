//
//  TableLayoutModifiers.swift
//  
//
//  Created by realszq on 2022/5/21.
//

import SwiftUI

// MARK: - Table Separator
struct TableSeparator: Shape {
    static let role: ShapeRole = .stroke
    
    let shouldDrawBorder: Bool
    let columnWidths: [CGFloat]
    let rowHeights: [CGFloat]
    
    func verticalSeparatorLines(in rect: CGRect) -> [(CGPoint, CGPoint)] {
        guard !columnWidths.isEmpty else { return [] }
        
        var xPos = rect.origin.x
        return columnWidths.prefix(columnWidths.count - 1).map { (columnWidth) -> (CGPoint, CGPoint) in
            xPos += columnWidth
            return (CGPoint(x: xPos, y: rect.origin.y), CGPoint(x: xPos, y: rect.origin.y + rect.height))
        }
    }
    
    func horizontalSeparatorLines(in rect: CGRect) -> [(CGPoint, CGPoint)] {
        guard !rowHeights.isEmpty else { return [] }
        
        var yPos = rect.origin.y
        return rowHeights.prefix(rowHeights.count - 1).map { (rowHeight) -> (CGPoint, CGPoint) in
            yPos += rowHeight
            return (CGPoint(x: rect.origin.x, y: yPos), CGPoint(x: rect.origin.x + rect.width, y: yPos))
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if shouldDrawBorder {
            path.addRect(rect)
        }
        
        let lines = verticalSeparatorLines(in: rect) + horizontalSeparatorLines(in: rect)
        for (fromPoint, toPoint) in lines {
            path.move(to: fromPoint)
            path.addLine(to: toPoint)
        }
        
        return path
    }
}

struct TableSeparatorDrawing: ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var separatorWidth: CGFloat { max(0.5, (1 / 17) * dynamicTypeSize.bodyFontSize) }
    
    @EnvironmentObject var tableLayoutContext: TableLayoutContext
    
    var shouldDrawBorder: Bool { tableLayoutContext.columnCount == 1 || tableLayoutContext.rowCount == 1 }
    var columnWidths: [CGFloat] { tableLayoutContext.hasAllSizeAcquired ? tableLayoutContext.columnWidths.map({ $0! }) : [] }
    var rowHeights: [CGFloat] { tableLayoutContext.hasAllSizeAcquired ? tableLayoutContext.rowHeights.map({ $0! }) : [] }
    
    var separatorLineWidth: CGFloat { tableLayoutContext.isColumnWidthValid ? separatorWidth : 0 } // hide separator when invalid
#if os(iOS)
    let strokeColor = Color(uiColor: .separator)
#elseif os(macOS)
    let strokeColor = Color(nsColor: .separatorColor)
#endif
    func body(content: Content) -> some View {
        content
            .background(
                TableSeparator(shouldDrawBorder: shouldDrawBorder, columnWidths: columnWidths, rowHeights: rowHeights)
                    .stroke(strokeColor, lineWidth: separatorLineWidth)
            )
    }
}

// MARK: - Cell Layout
struct TableLayout: ViewModifier {
    let id: AnyHashable
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var cellVerticalMargin: CGFloat { (10 / 17) * dynamicTypeSize.bodyFontSize }
    var cellHorizontalMargin: CGFloat { (15 / 17) * dynamicTypeSize.bodyFontSize }

    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    @EnvironmentObject var tableLayoutContext: TableLayoutContext
    
    var width: CGFloat? { tableLayoutContext.width(for: id) }
    var alignment: Alignment { tableLayoutContext.alignment(for: id).viewAlignment(for: layoutDirection) }
    
    func body(content: Content) -> some View {
        content
            .padding([.top, .bottom], cellVerticalMargin)
            .padding([.leading, .trailing], cellHorizontalMargin)
            .frame(maxWidth: width, alignment: alignment)
            .onSizeChange { newSize in
                guard newSize != .zero else { return }
                tableLayoutContext.update(cellSize: newSize, for: id)
            }
    }
}

extension View {
    func tableLayouted(id: AnyHashable) -> some View {
        modifier(TableLayout(id: id))
    }
    
    func drawTableSeparator() -> some View {
        modifier(TableSeparatorDrawing())
    }
}
