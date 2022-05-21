//
//  TableCellView.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import SwiftUI

struct TableCellView: View {
    let tableCellBlock: TableCellBlock
    
    var body: some View {
        Text(tableCellBlock.attrStr)
            .tableLayouted(id: tableCellBlock.id)
    }
}
