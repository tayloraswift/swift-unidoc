import MarkdownABI
import SwiftIDEUtils

extension MarkdownBytecode.Context
{
    init?(classification:SyntaxClassification)
    {
        switch classification
        {
        case    .none,
                .editorPlaceholder:     return nil

        case    .attribute:             self = .attribute

        case    .ifConfigDirective:     self = .directive

        case    .lineComment,
                .blockComment:          self = .comment
        case    .docLineComment,
                .docBlockComment:       self = .doccomment

        case    .dollarIdentifier:      self = .pseudo
        case    .identifier:            self = .identifier
        case    .operator:              self = .operator

        case    .integerLiteral,
                .floatLiteral:          self = .literalNumber
        case    .stringLiteral,
                .regexLiteral:          self = .literalString

        case    .keyword:               self = .keyword
        case    .type:                  self = .type
        }
    }
}
