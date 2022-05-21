//
//  TableLayoutModifiers.swift
//  
//
//  Created by realszq on 2022/5/21.
//

import SwiftUI

// MARK: - Table Separator
struct TableSeparator: Shape {
    @ObservedObject var tableLayoutContext: TableLayoutContext
    
    func verticalSeparatorLines(in rect: CGRect) -> [(CGPoint, CGPoint)] {
        let columnWidths = tableLayoutContext.columnWidths.map({ $0! })
        var xPos = rect.origin.x
        return columnWidths.prefix(columnWidths.count - 1).map { (columnWidth) -> (CGPoint, CGPoint) in
            xPos += columnWidth
            return (CGPoint(x: xPos, y: rect.origin.y), CGPoint(x: xPos, y: rect.origin.y + rect.height))
        }
    }
    
    func horizontalSeparatorLines(in rect: CGRect) -> [(CGPoint, CGPoint)] {
        let rowHeights = tableLayoutContext.rowHeights.map({ $0! })
        var yPos = rect.origin.y
        return rowHeights.prefix(rowHeights.count - 1).map { (rowHeight) -> (CGPoint, CGPoint) in
            yPos += rowHeight
            return (CGPoint(x: rect.origin.x, y: yPos), CGPoint(x: rect.origin.x + rect.width, y: yPos))
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard tableLayoutContext.isColumnWidthValid && tableLayoutContext.hasAllSizeAcquired else { return path }
        
        for (fromPoint, toPoint) in verticalSeparatorLines(in: rect) + horizontalSeparatorLines(in: rect) {
            path.move(to: fromPoint)
            path.addLine(to: toPoint)
        }
        
        return path
    }
}

struct TableSeparatorModifier: ViewModifier {
    var tableLayoutContext: TableLayoutContext
#if os(iOS)
    let strokeColor = Color(uiColor: .separator)
#elseif os(macOS)
    let strokeColor = Color(nsColor: .separatorColor)
#endif
    func body(content: Content) -> some View {
        content
            .background(
                TableSeparator(tableLayoutContext: tableLayoutContext)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
}


// MARK: - Cell Layout
struct TableLayout: ViewModifier {
    let id: AnyHashable
    
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    @EnvironmentObject var tableLayoutContext: TableLayoutContext
    
    var width: CGFloat? { tableLayoutContext.width(for: id) }
    var alignment: Alignment { tableLayoutContext.alignment(for: id).viewAlignment(for: layoutDirection) }
    
    func body(content: Content) -> some View {
        content
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 15)
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
    
    func drawTableSeparator(tableLayoutContext: TableLayoutContext) -> some View {
        modifier(TableSeparatorModifier(tableLayoutContext: tableLayoutContext))
    }
}
