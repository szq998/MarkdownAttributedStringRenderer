//
//  MarkdownAttributedStringParser.swift
//  MarkdownAttributedStringRenderer
//
//  Created by realszq on 2022/5/15.
//

import SwiftUI

class MarkdownAttributedStringParser {
    let attrStr: AttributedString
    init(_ attrStr: AttributedString) { self.attrStr = attrStr }
    
    typealias Presentation = PresentationIntent
    typealias Intent = PresentationIntent.IntentType
    typealias Index = AttributedString.Index
    
    // MARK: - Manage block id
    private var blockIDSet = Set<Int>()
    private func id(for hashed: AnyHashable) -> Int {
        var hasher = Hasher()
        hasher.combine(hashed)
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
    // MARK: - Block Nesting Relationship
    private var nestingIntents: [Intent] = []
    private var nestingChildrenSeqs: [ContainerRenderableBlock.Children] = []
    private var currentChildren: [RenderableBlock] {
        get { nestingChildrenSeqs.last! }
        set {
            let lastIdx = nestingChildrenSeqs.index(before: nestingChildrenSeqs.endIndex)
            nestingChildrenSeqs[lastIdx] = newValue
        }
    }
    // record start index to figure oute id for the whole container when container ended
    private var containerIntent2StartIndex: [Intent : Index] = [:]
    
    private func makeContentBlock(for presentation: Presentation, at range: Range<Index>) -> RenderableBlock {
        // remove intents for container
        let containerIntentsRemoved = presentation.withContainerIntentsRemoved
        
        var subAttrStr = AttributedString(attrStr[range])
        subAttrStr.presentationIntent = containerIntentsRemoved
        
        let id = id(for: subAttrStr)
        
        if containerIntentsRemoved.isThematicBreak {
            return ThematicBreakBlock(id: id)
        } else if let headerLevel = containerIntentsRemoved.headerLevel {
            return HeaderBlock(attrStr: subAttrStr, id: id, headerLevel: headerLevel)
        } else if let codeHint = containerIntentsRemoved.codeLangHint {
            return CodeBlock(attrStr: subAttrStr, id: id, conLangHint: codeHint)
        } else {
            return ParagraphBlock(attrStr: subAttrStr, id: id)
        }
    }
    
    private func makeContainerBlock(for intent: Intent, endedAt index: Index, with children: [RenderableBlock]) -> ContainerRenderableBlock {
        let endedIntentStartIndex = containerIntent2StartIndex.removeValue(forKey: intent)!
        let containerRange = endedIntentStartIndex..<index
        let id = id(for: attrStr[containerRange])
        
        if let ordinal = intent.listItemOrdinal {
            return ListItemBlock(id: id, children: children, ordinal: ordinal)
        } else if intent.isList {
            // figure out nesting level
            let isOrdered = intent.isOrderedList
            
            var nestingLevel = 0
            for intent in nestingIntents.reversed() {
                // intent is of the same list type
                if intent.isListItem { continue }
                guard intent.isList && intent.isOrderedList == isOrdered else { break }
                nestingLevel += 1
            }
            return ListBlock(id: id, isOrdered: isOrdered, nestingLevel: nestingLevel, listItems: children as! [ListItemBlock])
        } else if intent.kind == .blockQuote {
            // firgure out is outermost
            var isOutermost = true
            for intent in nestingIntents.prefix(nestingIntents.count - 1) {
                if intent.kind == .blockQuote {
                    isOutermost = false
                    break
                }
            }
            return BlockquoteBlock(id: id, isOutermost: isOutermost, children: children)
        } else {
            fatalError("Not implemented")
        }
    }
    
    private func gatherEndedContainers(_ endedIntents: Set<Intent>, endedAt index: Index) {
        let intentsFromDeepToShallow = endedIntents.sorted(by: { Intent.isInDeeperLevel(of: $0, comparedTo: $1) })
        intentsFromDeepToShallow.forEach { intent in
            let children = nestingChildrenSeqs.popLast()!
            let block = makeContainerBlock(for: intent, endedAt: index, with: children)
            currentChildren.append(block)
            
            nestingIntents.removeLast()
        }
    }
    
    private func prepareNewContainers(_ newIntents: Set<Intent>, startedAt index: Index) {
        let intentsFromShallowToDeep = newIntents.sorted(by: { Intent.isInDeeperLevel(of: $1, comparedTo: $0) }) // TODO: components array itself is  already ordered?
        
        nestingIntents += intentsFromShallowToDeep
        
        intentsFromShallowToDeep.forEach { intent in
            containerIntent2StartIndex[intent] = index
            nestingChildrenSeqs.append([])
        }
    }
    
    private var lastContainerIntent: Set<Intent> = []
    private func containerIntentDiff(_ currIntents: Set<Intent>) -> (new: Set<Intent>, ended: Set<Intent>) {
        defer { lastContainerIntent = currIntents }
        return (
            currIntents.subtracting(lastContainerIntent),
            lastContainerIntent.subtracting(currIntents)
        )
    }
    
    private var parsedDocument: Document?
    func parse() -> Document {
        if parsedDocument == nil {
            nestingChildrenSeqs.append([/* this empty initial children is for the whole Document */])
            
            for (presentation, range) in attrStr.runs[\.presentationIntent] {
                guard let presentation = presentation else { continue } // TODO: should handle nil intent block?
                
                // handle container block
                let containerIntents = Set(presentation.containerBlockIntents)
                let (newContainerIntents, endedContainerIntents) = containerIntentDiff(containerIntents)
                gatherEndedContainers(endedContainerIntents, endedAt: range.upperBound)
                prepareNewContainers(newContainerIntents, startedAt: range.upperBound)
                
                let currBlock: RenderableBlock = makeContentBlock(for: presentation, at: range)
                currentChildren.append(currBlock)
            }
            
            gatherEndedContainers(lastContainerIntent, endedAt: attrStr.endIndex)
            let id = id(for: attrStr)
            parsedDocument = Document(id: id, children: currentChildren)
        }
        return parsedDocument!
    }
}

fileprivate extension PresentationIntent.IntentType {
    var isList: Bool { kind == .orderedList || kind == .unorderedList }
    var isOrderedList: Bool { kind == .orderedList }
    var isListItem: Bool {
        switch self.kind {
        case .listItem(ordinal: _):
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
    var isContainer: Bool {  kind == .orderedList || kind == .unorderedList || isListItem || kind == .blockQuote }
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
    var listIntents: [PresentationIntent.IntentType] { components.filter({ $0.kind == .orderedList || $0.kind == .unorderedList }) }
    var listItemIntents: [PresentationIntent.IntentType] { components.filter({ $0.isListItem }) }
    
    var isInBlockquote: Bool { components.map({ $0.kind }).contains(.blockQuote) }
    var blockquoteIntents: [PresentationIntent.IntentType] { components.filter({ $0.kind == .blockQuote }) }
    
    var isInContainerBlock: Bool { isInList || isInBlockquote }
    var containerBlockIntents: [PresentationIntent.IntentType] { components.filter({ $0.isContainer }) }
    var nonContainerBlockIntents: [PresentationIntent.IntentType] { components.filter({ !$0.isContainer }) }
    
    var withContainerIntentsRemoved: Self {
        let nonContainerIntents = nonContainerBlockIntents
        return Self(types: nonContainerIntents)
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
