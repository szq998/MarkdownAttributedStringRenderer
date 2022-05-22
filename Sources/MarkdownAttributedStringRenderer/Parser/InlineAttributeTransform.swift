//
//  File.swift
//  
//
//  Created by realszq on 2022/5/19.
//

import Foundation

/// Remove any characters with "softBreak" or "LineBreak" inline presentation intent and replace those with a single new line character.
/// - Parameter attrStr: The attributedString for replacing.
func replaceInlineLineBreakIntentWithNewLineChar(_ attrStr: inout AttributedString) {
    for (inlineIntent, range) in attrStr.runs[\.inlinePresentationIntent].reversed()
    where (inlineIntent == .softBreak && range.lowerBound != attrStr.endIndex) // ignore softBreak at the end of a block
    || inlineIntent == .lineBreak
    {
        attrStr.characters.replaceSubrange(range, with: "\n")
    }
}
