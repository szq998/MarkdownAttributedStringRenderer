//
//  MarkdownAttributedStringParser.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

actor MarkdownAttributedStringParser {
    public func parse(_ attrStr: AttributedString) -> Document {
        let docDigest = digest(for: attrStr)
        if let cachedDocument = cachedDocument, cachedDocument.digest == docDigest {
            return cachedDocument
        }
        
        resetEnvironment()
        self.attrStr = attrStr
        
        let documnet: Document
        if cache.isEmpty { documnet = parse() }
        else { documnet = parseWithCacheAwareness() }
        
        cache = buildingCache
        cachedDocument = documnet
        
        return documnet
    }
    
    private var attrStr: AttributedString = ""
    
    typealias Presentation = PresentationIntent
    typealias Intent = PresentationIntent.IntentType
    typealias Index = AttributedString.Index
    
    // MARK: - Generate Block Digest
    private func digest(for attrStr: AttributedString) -> AnyHashable {
        var hasher = Hasher()
        hasher.combine(attrStr)
        return hasher.finalize()
    }
    
    // MARK: - Block Nesting Relationship
    private var nestingIntents: [Intent] = []
    private var nestingChildrenSeqs: [ContainerMarkdownBlock.Children] = []
    private var currentChildren: [MarkdownBlock] {
        get { nestingChildrenSeqs.last! }
        set {
            let lastIdx = nestingChildrenSeqs.index(before: nestingChildrenSeqs.endIndex)
            nestingChildrenSeqs[lastIdx] = newValue
        }
    }
    // record start index to figure oute id for the whole container when container ended
    private var containerIntent2StartIndex: [Intent : Index] = [:]
    
    private func makeContentBlock(for presentation: Presentation, at range: Range<Index>) -> MarkdownBlock {
        // remove intents for container
        let containerIntentsRemoved = presentation.withContainerIntentComponentsRemovedAndIDNormalized
        
        var subAttrStr = AttributedString(attrStr[range])
        subAttrStr.presentationIntent = containerIntentsRemoved
        let digest = digest(for: subAttrStr)
        
        // test cache
        if let cachedBlk = getCache(for: digest) {
            return cachedBlk
        }
        
        let block: MarkdownBlock
        
        if containerIntentsRemoved.isThematicBreak {
            block = ThematicBreakBlock(digest: digest)
        } else if let headerLevel = containerIntentsRemoved.headerLevel {
            block = HeaderBlock(digest: digest, attrStr: subAttrStr, headerLevel: headerLevel)
        } else if let codeHint = containerIntentsRemoved.codeLangHint {
            block = CodeBlock(digest: digest, attrStr: subAttrStr, conLangHint: codeHint)
        } else if containerIntentsRemoved.isTableCell {
            block = TableCellBlock(digest: digest, attrStr: subAttrStr)
        } else {
            block = ParagraphBlock(digest: digest, attrStr: subAttrStr)
        }
        
        setCache(block, for: digest)
        return block
    }
    
    private func getListNestingLevel(isOrdered: Bool) -> Int {
        var nestingLevel = 1
        for intent in nestingIntents.reversed() {
            // intent is of the same list type
            if intent.isListItem { continue } // skip list item intent
            guard intent.isList && intent.isOrderedList == isOrdered else { break }
            nestingLevel += 1
        }
        return nestingLevel
    }
    
    private func isInOutermostBlockquote() -> Bool {
        !nestingIntents.contains(where: { $0.kind == .blockQuote })
    }
    
    private func makeContainerBlock(for intent: Intent, endedAt index: Index, with children: [MarkdownBlock]) -> ContainerMarkdownBlock {
        let endedIntentStartIndex = containerIntent2StartIndex.removeValue(forKey: intent)!
        let containerRange = endedIntentStartIndex..<index
        
        let slice = AttributedString(attrStr[containerRange])
        var normalized = slice
        normalized.removeOuterPresentationIntentComponentsAndNormalizeID(for: intent)
        
        let digest = digest(for: normalized)
        let block: ContainerMarkdownBlock
        
        if intent.isListItem {
            block = ListItemBlock(digest: digest, children: children)
            
        } else if intent.isList {
            // figure out nesting level
            let isOrdered = intent.isOrderedList
            let nestingLevel = getListNestingLevel(isOrdered: isOrdered)
            block = ListBlock(digest: digest, isOrdered: isOrdered, nestingLevel: nestingLevel, listItems: children as! [ListItemBlock])
            
        } else if intent.kind == .blockQuote {
            // firgure out is outermost
            let isOutermost = isInOutermostBlockquote()
            block = BlockquoteBlock(digest: digest, isOutermost: isOutermost, children: children)
            
        } else if intent.isTableRow {
            block = TableRowBlock(digest: digest, tableCells: children as! [TableCellBlock])
            
        } else if let tableColumns = intent.tableColumns {
            block = TableBlock(digest: digest, tableColumnAlignments: tableColumns.map({ $0.alignment }), tableRows: children as! [TableRowBlock])
            
        } else { fatalError("Not implemented") }
        
        setCache(block, for: digest)
        return block
    }
    
    private func gatherEndedContainers(_ endedIntents: Set<Intent>, endedAt index: Index) {
        let intentsFromDeepToShallow = endedIntents.sorted(by: { Intent.isInDeeperLevel(of: $0, comparedTo: $1) })
        intentsFromDeepToShallow.forEach { intent in
            nestingIntents.removeLast()
            
            let children = nestingChildrenSeqs.popLast()!
            let block = makeContainerBlock(for: intent, endedAt: index, with: children)
            currentChildren.append(block)
        }
    }
    
    private func prepareNewContainers(_ newIntents: Set<Intent>, startedAt index: Index) {
        let intentsFromShallowToDeep = newIntents.sorted(by: { Intent.isInDeeperLevel(of: $1, comparedTo: $0) }) // TODO: components array itself is already ordered?
        
        nestingIntents += intentsFromShallowToDeep
        
        intentsFromShallowToDeep.forEach { intent in
            containerIntent2StartIndex[intent] = index
            nestingChildrenSeqs.append([])
        }
    }
    
    private var lastContainerIntents: Set<Intent> = []
    private func containerIntentDiff(_ currIntents: Set<Intent>) -> (new: Set<Intent>, ended: Set<Intent>) {
        defer { lastContainerIntents = currIntents }
        return (
            currIntents.subtracting(lastContainerIntents),
            lastContainerIntents.subtracting(currIntents)
        )
    }
    
    private func resetEnvironment() {
        nestingIntents = []
        nestingChildrenSeqs = []
        containerIntent2StartIndex = [:]
        lastContainerIntents = []
        
        buildingCache = [:]
    }
    
    private func parse() -> Document {
        nestingChildrenSeqs.append([/* this empty initial children is for the whole Document */])
        
        for (presentation, range) in attrStr.runs[\.presentationIntent] {
            guard let presentation = presentation else { continue } // TODO: should handle nil intent block?
            
            // handle container block
            let containerIntents = Set(presentation.containerIntentComponents)
            let (newContainerIntents, endedContainerIntents) = containerIntentDiff(containerIntents)
            gatherEndedContainers(endedContainerIntents, endedAt: range.lowerBound)
            prepareNewContainers(newContainerIntents, startedAt: range.lowerBound)
            
            let currBlock = makeContentBlock(for: presentation, at: range)
            currentChildren.append(currBlock)
        }
        gatherEndedContainers(lastContainerIntents, endedAt: attrStr.endIndex)
        
        let digest = digest(for: attrStr)
        return Document(digest: digest, children: currentChildren)
    }
    
    // MARK: - Parse with cache
    private var cachedDocument: Document?
    private var cache: [AnyHashable: MarkdownBlock] = [:]
    private var buildingCache: [AnyHashable : MarkdownBlock] = [:] // Map the block attributed string's hash to parsed block
    
    private func setCache(_ block: MarkdownBlock, for digest: AnyHashable) {
        buildingCache[digest] = block
    }
    
    private func cacheChildren(for containerBlock: ContainerMarkdownBlock) {
        for child in containerBlock.children {
            guard !buildingCache.keys.contains(child.digest) else { continue }
            
            buildingCache[child.digest] = child
            if let container = child as? ContainerMarkdownBlock {
                cacheChildren(for: container)
            }
        }
    }
    
    private func getCache(for digest: AnyHashable) -> MarkdownBlock? {
        if let cached = buildingCache[digest] {
            return cached
        } else if let cached = cache[digest] {
            // add to current run's cache
            buildingCache[digest] = cached
            if let cachedContainer = cached as? ContainerMarkdownBlock {
                // also add children to current run's cache
                cacheChildren(for: cachedContainer)
            }
            return cached
        }
        return nil
    }
    
    private func sliceWithOuterIntentsRemovedAndNormalized(for intent: Intent, startedAt index: Index) -> (subStr: AttributedString, endIndex: Index) {
        var slicingEndIndex = attrStr.endIndex
        for (presentation, range) in attrStr.runs[\.presentationIntent][index...] {
            guard let presentation = presentation else { continue }
            if !presentation.contains(intent) {
                slicingEndIndex = range.lowerBound
                break
            }
        }
        var slice = AttributedString(attrStr[index..<slicingEndIndex])
        // remove outer intents
        slice.removeOuterPresentationIntentComponentsAndNormalizeID(for: intent)
        return (slice, slicingEndIndex)
    }
    
    private func getCache(for intent: Intent, startedAt index: Index) -> (cache: MarkdownBlock, cacheEndIndex: Index)? {
        let (slice, endIndex) = sliceWithOuterIntentsRemovedAndNormalized(for: intent, startedAt: index)
        let digest = digest(for: slice)
        
        if let cache = getCache(for: digest) {
            return (cache, endIndex)
        } else {
            return nil
        }
    }
    
    private func prepareNewContainersWithCacheAwareness(_ newIntents: Set<Intent>, startedAt index: Index) -> (skippedIntents: Set<Intent> , cacheEndIndex: Index)? {
        let intentsFromShallowToDeep = newIntents.sorted(by: { Intent.isInDeeperLevel(of: $1, comparedTo: $0) }) // TODO: components array itself is already ordered?
        
        for (intentIdx, intent) in intentsFromShallowToDeep.enumerated() {
            if let (cachedBlock, cacheEndIndex) = getCache(for: intent, startedAt: index) {
                // special care for list and blockquote
                if var listBlock = cachedBlock as? ListBlock {
                    // figure oute nesting level
                    listBlock.nestingLevel = getListNestingLevel(isOrdered: intent.isOrderedList)
                    currentChildren.append(listBlock)
                } else if var blockquoteBlock = cachedBlock as? BlockquoteBlock {
                    // figure out isOutermost
                    blockquoteBlock.isOutermost = isInOutermostBlockquote()
                    currentChildren.append(blockquoteBlock)
                } else {
                    currentChildren.append(cachedBlock)
                }
                // report which part is cached
                let skippedIntents = Set(intentsFromShallowToDeep[intentIdx...])
                return (skippedIntents, cacheEndIndex)
            }
            containerIntent2StartIndex[intent] = index
            nestingChildrenSeqs.append([])
            nestingIntents.append(intent)
        }
        return nil
    }
    
    private func parseWithCacheAwareness() -> Document {
        // parse
        nestingChildrenSeqs.append([/* this empty initial children is for the whole Document */])
        var jumpToIndex: Index?
        for (presentation, range) in attrStr.runs[\.presentationIntent] {
            if let idx = jumpToIndex {
                if idx > range.lowerBound { continue }
                else { jumpToIndex = nil }
            }
            guard let presentation = presentation else { continue } // TODO: should handle nil intent block?
            
            // handle container block
            let containerIntents = Set(presentation.containerIntentComponents)
            let (newContainerIntents, endedContainerIntents) = containerIntentDiff(containerIntents)
            gatherEndedContainers(endedContainerIntents, endedAt: range.lowerBound)
            if let (skippedIntents, cacheEndIndex) = prepareNewContainersWithCacheAwareness(newContainerIntents, startedAt: range.lowerBound) {
                // cache hit
                jumpToIndex = cacheEndIndex
                lastContainerIntents.subtract(skippedIntents)
            } else {
                let currBlock = makeContentBlock(for: presentation, at: range)
                currentChildren.append(currBlock)
            }
        }
        gatherEndedContainers(lastContainerIntents, endedAt: attrStr.endIndex)
        
        let docDigest = digest(for: attrStr)
        return Document(digest: docDigest, children: currentChildren)
    }
}

fileprivate extension AttributedString {
    mutating func removeOuterPresentationIntentComponentsAndNormalizeID(for intentComponent: PresentationIntent.IntentType) {
        for (presentation, range) in self.runs[\.presentationIntent] {
            guard let presentation = presentation else { continue }
            self[range].presentationIntent = presentation.withOuterIntentComponentsRemovedAndIDNormalized(for: intentComponent)
        }
    }
}

fileprivate extension PresentationIntent.IntentType {
    var isList: Bool { kind == .orderedList || kind == .unorderedList }
    var isOrderedList: Bool { kind == .orderedList }
    var isListItem: Bool {
        switch kind {
        case .listItem(ordinal: _):
            return true
        default:
            return false
        }
    }
    var isTable: Bool {
        switch kind {
        case .table(columns: _):
            return true
        default:
            return false
        }
    }
    
    var tableColumns: [PresentationIntent.TableColumn]? {
        switch kind {
        case .table(columns: let columns):
            return columns
        default:
            return nil
        }
    }
    
    var isTableHeaderRow: Bool {
        kind == .tableHeaderRow
    }
    var isTableBodyRow: Bool {
        switch kind {
        case .tableRow(rowIndex: _):
            return true
        default:
            return false
        }
    }
    var isTableRow: Bool { isTableHeaderRow || isTableBodyRow }
    
    var isTableCell: Bool {
        switch kind {
        case .tableCell(columnIndex: _):
            return true
        default:
            return false
        }
    }
    
    var listItemOrdinal: Int? {
        switch kind {
        case .listItem(ordinal: let ordinal):
            return ordinal
        default:
            return nil
        }
    }
    var isContainer: Bool {
        kind == .orderedList || kind == .unorderedList || isListItem
        || kind == .blockQuote
        || isTable || isTableRow
    }
    
    mutating func normalizeIntentKind() {
        switch kind {
        case .listItem(ordinal: _):
            kind = .listItem(ordinal: 1)
        case .tableHeaderRow, .tableRow(rowIndex: _):
            kind = .tableRow(rowIndex: 1)
        case .tableCell(columnIndex: _):
            kind = .tableCell(columnIndex: 1)
        default:
            break
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
    var isInList: Bool { components.contains(where: { $0.isListItem }) }
    var isInBlockquote: Bool { components.map({ $0.kind }).contains(.blockQuote) }
    var isTableCell: Bool { components.contains(where: { $0.isTableCell }) }
    
    var containerIntentComponents: [PresentationIntent.IntentType] { components.filter({ $0.isContainer }) }
    var nonContainerIntentComponents: [PresentationIntent.IntentType] { components.filter({ !$0.isContainer }) }
    
    var withContainerIntentComponentsRemovedAndIDNormalized: Self {
        var nonContainerIntents = nonContainerIntentComponents
        assert(nonContainerIntents.count == 1)
        nonContainerIntents[0].identity = 1
        nonContainerIntents[0].normalizeIntentKind()
        return Self(types: nonContainerIntents)
    }
    
    func withOuterIntentComponentsRemovedAndIDNormalized(for intentComponent: IntentType) -> Self {
        let origIntentsFromDeepToShallow = components.sorted(by: { IntentType.isInDeeperLevel(of: $0, comparedTo: $1) })
        guard let targetIndex = origIntentsFromDeepToShallow.firstIndex(of: intentComponent) else { return self }
        
        var slicedIntents = (origIntentsFromDeepToShallow[0...targetIndex])
        let IDDec = intentComponent.identity - 1
        slicedIntents.indices.forEach { idx in
            slicedIntents[idx].identity -= IDDec
            slicedIntents[idx].normalizeIntentKind()
        }
        return Self(types: Array(slicedIntents))
    }
    
    func contains(_ intentType: IntentType) -> Bool {
        for component in components {
            if component == intentType {
                return true
            }
        }
        return false
    }
}

protocol IntentDepthComparable {
    static func isInDeeperLevel(of it1: Self, comparedTo it2: Self) -> Bool
}
extension PresentationIntent.IntentType: IntentDepthComparable {
    // determine nesting level according to intent identity (the larger, the deeper). Identity may not have the purpose of nesting depth, but it seems the only way to figure out depth in some cases
    static func isInDeeperLevel(of it1: PresentationIntent.IntentType, comparedTo it2: PresentationIntent.IntentType) -> Bool {
        it1.identity > it2.identity
    }
}
