import IDEUtils
import MarkdownABI

extension MarkdownBytecode.Context
{
    init?(classification:SyntaxClassification)
    {
        switch classification
        {
        case    .none,
                .editorPlaceholder:         return nil

        case    .attribute:                 self = .attribute

        case    .buildConfigId:             self = .directive
        case    .poundDirectiveKeyword:     self = .magic

        case    .lineComment,
                .blockComment:              self = .comment
        case    .docLineComment,
                .docBlockComment:           self = .doccomment

        case    .dollarIdentifier:          self = .pseudo
        case    .identifier:                self = .identifier
        case    .operatorIdentifier:        self = .operator

        case    .integerLiteral,
                .floatingLiteral:           self = .literalNumber
        case    .stringLiteral,
                .objectLiteral:             self = .literalString

        case    .keyword:                   self = .keyword
        case    .stringInterpolationAnchor: self = .interpolation
        case    .typeIdentifier:            self = .type
        }
    }
}
