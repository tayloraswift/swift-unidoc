import MarkdownAST

extension Markdown
{
    enum BlockPrefix:Equatable, Hashable, Sendable
    {
        case parameter  (Markdown.ParameterPrefix)
        case term       (Markdown.TermPrefix)
        case keywords   (Markdown.KeywordPrefix)
    }
}
extension Markdown.BlockPrefix:Markdown.SemanticPrefix
{
    static
    var radius:Int { 4 }

    init?(from elements:__shared [Markdown.InlineElement])
    {
        if  let parameter:Markdown.ParameterPrefix = .init(from: elements)
        {
            self = .parameter(parameter)
        }
        else if
            let term:Markdown.TermPrefix = .init(from: elements)
        {
            self = .term(term)
        }
        else if
            let keywords:Markdown.KeywordPrefix = .init(from: elements)
        {
            self = .keywords(keywords)
        }
        else
        {
            return nil
        }
    }
}
