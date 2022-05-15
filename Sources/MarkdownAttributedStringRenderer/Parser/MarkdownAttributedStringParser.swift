//
//  MarkdownAttributedStringParser.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

class MarkdownAttributedStringParser {
    static let shared = MarkdownAttributedStringParser()
    private init() { }
    
    // MARK: - Manage block id
    private var blockIDSet = Set<Int>()
    private func idForSubRange(attrStr: AttributedString) -> Int {
        var hasher = Hasher()
        hasher.combine(attrStr)
        if blockIDSet.contains(hasher.finalize()) {
            var deDup = 0
            while blockIDSet.contains(hasher.finalize()) {
                hasher.combine(deDup)
                deDup += 1
            }
        }
        let id = hasher.finalize()
        blockIDSet.insert(id)
        return id
    }
    
    // MARK: - Handle list state
    private var containingLists: [PresentationIntent.IntentType] = []
    private var containingListItems: [PresentationIntent.IntentType] = []
    
    private var lastListIntents: Set<PresentationIntent.IntentType> = []
    private var lastListItemIntents: Set<PresentationIntent.IntentType> = []
    
    private enum ListForward {
        case `continue` // exact the same list but not in a list. eg complex list item with header and paragraph will break into two blocks
        case nextItem(newItem: PresentationIntent.IntentType)
        case nestedListBegin(newList: PresentationIntent.IntentType, newItem: PresentationIntent.IntentType)
        case nestedListEndAndNextItem(endedListCount: Int, endedItemCount: Int, newItem: PresentationIntent.IntentType)
        case nestedListEndAndNextList(endedCount: Int, newList: PresentationIntent.IntentType, newItem: PresentationIntent.IntentType)
        case listEnd(endedCount: Int)
        
        case notInList
    }
    
    private func listIntentDiff(_ lists: Set<PresentationIntent.IntentType>, _ items: Set<PresentationIntent.IntentType>) -> ListForward {
        guard !(containingLists.isEmpty && containingListItems.isEmpty && lists.isEmpty && items.isEmpty) else { return .notInList }
        
        let removedLists: Set<PresentationIntent.IntentType> = lastListIntents.subtracting(lists)
        let addedLists: Set<PresentationIntent.IntentType> = lists.subtracting(lastListIntents)
        let removedItems: Set<PresentationIntent.IntentType> = lastListItemIntents.subtracting(items)
        let addedItems: Set<PresentationIntent.IntentType> = items.subtracting(lastListItemIntents)
        
        lastListIntents = lists
        lastListItemIntents = items
        
        if !lists.isEmpty && !items.isEmpty
            && removedLists.isEmpty && addedLists.isEmpty
            && removedItems.isEmpty && addedItems.isEmpty
        {
            return .continue
        }
        
        if removedLists.isEmpty && addedLists.isEmpty
            && addedItems.count == 1 && removedItems.count == 1
        {
            return .nextItem(newItem: addedItems.first!)
        }
        
        if removedLists.isEmpty && addedLists.count == 1
            && removedItems.isEmpty && addedItems.count == 1
        {
            return .nestedListBegin(newList: addedLists.first!, newItem: addedItems.first!)
        }
        
        if removedLists.count > 0 && addedLists.isEmpty
            && removedItems.count > 0 && addedItems.count == 1
        {
            assert(removedLists.count == removedItems.count - 1)
            return .nestedListEndAndNextItem(endedListCount: removedLists.count, endedItemCount: removedItems.count, newItem: addedItems.first!)
        }
        
        if removedLists.count > 0 && addedLists.count == 1
            && removedItems.count > 0 && addedItems.count == 1
        {
            assert(removedLists.count == removedItems.count)
            return .nestedListEndAndNextList(endedCount: removedLists.count, newList: addedLists.first!, newItem: addedItems.first!)
        }
        
        if removedLists.count > 0 && addedLists.isEmpty
            && removedItems.count > 0 && addedItems.isEmpty
        {
            assert(removedLists.count == removedItems.count)
            return .listEnd(endedCount: removedLists.count)
        }
        
        fatalError("Impossible list forward")
    }
    
    typealias ListDescription = (hasDecorator: Bool, nestingLevel: Int, ordinal: Int?)
    
    private func updateListState(_ diff: ListForward) -> ListDescription {
        switch diff {
        case .continue:
            return (false, containingLists.count, nil)
            
        case .nextItem(let newItem):
            assert(!containingLists.isEmpty)
            containingListItems.removeLast()
            containingListItems.append(newItem)
            
        case .nestedListBegin(let newList, let newItem):
            containingLists.append(newList)
            containingListItems.append(newItem)
            
        case .nestedListEndAndNextItem(let endedListCount, let endedItemCount, let newItem):
            containingLists.removeLast(endedListCount)
            assert(!containingLists.isEmpty)
            containingListItems.removeLast(endedItemCount)
            containingListItems.append(newItem)
            
        case .nestedListEndAndNextList(let endedCount, let newList, let newItem):
            containingLists.removeLast(endedCount)
            containingListItems.removeLast(endedCount)
            
            containingLists.append(newList)
            containingListItems.append(newItem)
            
        case .listEnd(_):
            containingLists = []
            containingListItems = []
            return (false, 0, nil)
            
        case .notInList:
            return (false, 0, nil)
        }
        return (true, containingLists.count, containingLists.last!.isOrderedList ? containingListItems.last!.listItemOrdinal : nil)
    }
    
    // MARK: - Parse
    private func resetEnvironment() {
        blockIDSet = []
        containingLists = []
        containingListItems = []
        lastListIntents = []
        lastListItemIntents = []
    }
    
    func parse(_ attrStr: AttributedString) -> [RenderableMarkdownBlock] {
        // reset environment
        resetEnvironment()
        
        return attrStr.runs[\.presentationIntent].map { (blockIntent, range) -> RenderableMarkdownBlock in
            let subRangeAttrStr = AttributedString(attrStr[range])
            // generate id for sub str, keep id stable if possible
            let id = idForSubRange(attrStr: subRangeAttrStr)
            // no presentation intent, skip
            guard let blockIntent = blockIntent else { return .init(attrStr: subRangeAttrStr, id: id) }
            // specail block
            if blockIntent.isThematicBreak {
                // thematicBreak is specail, cannot be contained by other block
                // return rightaway
                return RenderableMarkdownBlock.thematicBreak(with: id)
            }
            // the initial plain block
            var ret = RenderableMarkdownBlock(attrStr: subRangeAttrStr, id: id, indentationLevel: blockIntent.indentationLevel)
            
            // exclusive intents
            if blockIntent.isPlainParagraph {
                // do nothing
            } else if let headerLevel = blockIntent.headerLevel { // handle header
                let headerFont = headerLevel == 1
                ? Font.largeTitle
                : headerLevel  == 2
                ? Font.title
                : headerLevel == 3
                ? Font.title2
                : Font.title3
                
                let hasDividerBelow = headerLevel < 3
                let transformed = subRangeAttrStr.transformingAttributes(\.presentationIntent) { transformer in
                    transformer.replace(with: \.font, value: headerFont)
                }
                ret.attrStr = transformed
                ret.hasDividerBelow = hasDividerBelow
            } else if let codeLangeHint = blockIntent.codeLangHint {
                ret.codeLangHint = codeLangeHint
            }
            
            // inclusive intents
            
            // blockquote can contain other non list block
            if blockIntent.isInBlockquote {
                ret.isInBlockquote = true
                ret.indentationLevel -= 1 // blockquote will have extra indentation, should treat differently
            }
            
            // list block can contain other block
            let diff = listIntentDiff(Set(blockIntent.listIntents), Set(blockIntent.listItemIntents))
            let (hasDecorator, nestingLevel, ordinal) = updateListState(diff)
            if blockIntent.isInList {
                ret.listItemDecorator = ordinal == nil ? .unordered(isBlankDecorator: !hasDecorator, nestingLevel: nestingLevel) : .ordered(isBlankDecorator: !hasDecorator, nestingLevel: nestingLevel, ordinal: ordinal!)
            }
            
            return ret
        }
    }
}

fileprivate extension PresentationIntent.Kind {
    var isListItem: Bool {
        switch self {
        case .listItem(ordinal: _):
            return true
        default:
            return false
        }
    }
}

fileprivate extension PresentationIntent.IntentType {
    var isOrderedList: Bool {
        kind == .orderedList
    }
    var listItemOrdinal: Int? {
        switch kind {
        case .listItem(ordinal: let ordinal):
            return ordinal
        default:
            return nil
        }
    }
}

fileprivate extension PresentationIntent {
    var isPlainParagraph: Bool { components.map({ $0.kind }).allSatisfy({ $0 == .paragraph }) }
    var isThematicBreak: Bool { components.map({ $0.kind }).contains(.thematicBreak) }
    var headerLevel: Int? {
        for intentType in components {
            switch intentType.kind {
            case .header(level: let level):
                return level
            default:
                break
            }
        }
        return nil
    }
    var codeLangHint: String? {
        for intentType in components {
            switch intentType.kind {
            case .codeBlock(languageHint: let hint):
                return hint ?? ""
            default:
                break
            }
        }
        return nil
    }
    var isInList: Bool { components.map({ $0.kind }).contains(where: { $0.isListItem }) }
    var listIntents: [PresentationIntent.IntentType] { components.filter({ $0.kind == .orderedList || $0.kind == .unorderedList }) }
    var listItemIntents: [PresentationIntent.IntentType] { components.filter({ $0.kind.isListItem }) }
    var isInBlockquote: Bool { components.map({ $0.kind }).contains(.blockQuote) }
}
