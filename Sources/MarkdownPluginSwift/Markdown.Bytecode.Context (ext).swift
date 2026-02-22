import MarkdownABI
import SwiftIDEUtils

extension Markdown.Bytecode.Context {
    init?(classification: SyntaxClassification) {
        switch classification {
        case .none:                 return nil
        case .editorPlaceholder:    return nil
        case .argumentLabel:        self = .identifier
        case .attribute:            self = .attribute
        case .ifConfigDirective:    self = .directive
        case .lineComment:          self = .comment
        case .blockComment:         self = .comment
        case .docLineComment:       self = .doccomment
        case .docBlockComment:      self = .doccomment
        case .dollarIdentifier:     self = .pseudo
        case .identifier:           self = .identifier
        case .operator:             self = .operator
        case .integerLiteral:       self = .literalNumber
        case .floatLiteral:         self = .literalNumber
        case .stringLiteral:        self = .literalString
        case .regexLiteral:         self = .literalString
        case .keyword:              self = .keyword
        case .type:                 self = .type
        }
    }
}
