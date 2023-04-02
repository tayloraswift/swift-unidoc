@frozen public
enum MarkdownSyntaxHighlight:String, Equatable, Hashable, Sendable
{
    case comment
    case identifier
    case keyword
    case literal
    case magic
    case actor
    case `class`
    case type
    case `typealias`
}
