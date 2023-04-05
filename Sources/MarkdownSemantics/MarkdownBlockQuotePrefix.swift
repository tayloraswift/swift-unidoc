import MarkdownTrees

enum MarkdownBlockQuotePrefix:Equatable, Hashable, Sendable
{
    case parameter(MarkdownParameterPrefix)
    case aside(MarkdownAsidePrefix)
}
extension MarkdownBlockQuotePrefix:MarkdownSemanticPrefix
{
    static
    var radius:Int { 4 }

    init?(from elements:__shared [MarkdownTree.InlineBlock])
    {
        if      let parameter:MarkdownParameterPrefix = .init(from: elements)
        {
            self = .parameter(parameter)
        }
        else if let aside:MarkdownAsidePrefix = .init(from: elements)
        {
            self = .aside(aside)
        }
        else
        {
            return nil
        }
    }
}
