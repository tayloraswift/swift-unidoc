import MarkdownABI

extension Markdown.Bytecode.Context {
    var highlight: String {
        switch self {
        case .attribute: "attribute"
        case .binding: "binding"
        case .comment: "comment"
        case .directive: "directive"
        case .doccomment: "doccomment"
        case .identifier: "identifier"
        case .interpolation: "interpolation"
        case .keyword: "keyword"
        case .literalNumber: "literalNumber"
        case .literalString: "literalString"
        case .magic: "magic"
        case .operator: "operator"
        case .pseudo: "pseudo"
        case .actor: "actor"
        case .class: "class"
        case .type: "type"
        case .typealias: "typealias"
        case .indent: "indent"
        default: "(unknown)"
        }
    }
}
