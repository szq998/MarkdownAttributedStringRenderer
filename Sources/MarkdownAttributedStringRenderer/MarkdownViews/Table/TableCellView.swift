//
//  TableCellView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct TableCellView: View {
    let tableCellBlock: TableCellBlock
    
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    
    @EnvironmentObject var tableGeometryContext: TableGeometryContext
    var width: CGFloat? { tableGeometryContext.width(for: tableCellBlock.id) }
    var height: CGFloat? { tableGeometryContext.height(for: tableCellBlock.id) }
    var alignment: Alignment { tableGeometryContext.alignment(for: tableCellBlock.id).viewAlignment(for: layoutDirection) }
    
    var body: some View {
        Text(tableCellBlock.attrStr)
            .padding()
            .onSizeChange { size in
                guard size != .zero else { return }
                tableGeometryContext.update(cellSize: size, for: tableCellBlock.id)
            }
            .frame(width: width, height: height, alignment: alignment)
#if os(iOS)
            .border(Color(uiColor: .separator), width: 0.5)
#elseif os(macOS)
            .border(Color(nsColor: .separatorColor), width: 0.5)
#endif
    }
}

fileprivate struct ViewSizeKey: PreferenceKey {
    static let defaultValue = CGSize.zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

fileprivate struct SizeListening: ViewModifier {
    @State var size = CGSize.zero
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo -> Color in
                    // cannot directly use ".preferece(key: ViewSizeKey.self, value: geo.size)"
                    // trick to prevent zero size from geometry reader
                    DispatchQueue.main.async {
                        size = geo.size
                    }
                    return Color.clear
                }
            )
            .preference(key: ViewSizeKey.self, value: size)
    }
}

fileprivate extension View {
    func sizeListening() -> some View {
        modifier(SizeListening())
    }
    func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
        self
            .sizeListening()
            .onPreferenceChange(ViewSizeKey.self, perform: perform)
    }
}
