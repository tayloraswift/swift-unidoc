@frozen public
enum MarkdownSyntaxHighlight:String, Equatable, Hashable, Sendable
{
    case attribute      = "syntax-attribute"
    case binding        = "syntax-binding"
    case comment        = "syntax-comment"
    case directive      = "syntax-directive"
    case doccomment     = "syntax-doccomment"
    case identifier     = "syntax-identifier"
    case interpolation  = "syntax-interpolation"
    case keyword        = "syntax-keyword"
    case literalNumber  = "syntax-literal-number"
    case literalString  = "syntax-literal-string"
    case magic          = "syntax-magic"
    case `operator`     = "syntax-operator"
    case pseudo         = "syntax-pseudo"
    case actor          = "syntax-actor"
    case `class`        = "syntax-class"
    case type           = "syntax-type"
    case `typealias`    = "syntax-typealias"
}
extension MarkdownSyntaxHighlight:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
