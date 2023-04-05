import MarkdownTrees

enum MarkdownBlockItemPrefix:Equatable, Hashable, Sendable
{
    case parameters
    case parameter(MarkdownParameterPrefix)
    case aside(MarkdownAsidePrefix)
}
extension MarkdownBlockItemPrefix:MarkdownSemanticPrefix
{
    static
    var radius:Int { 4 }

    init?(from spans:__shared [MarkdownTree.InlineBlock])
    {
        fatalError("unimplemented")
    }
}
