import MarkdownAST

enum MarkdownBlockPrefix:Equatable, Hashable, Sendable
{
    case parameter(MarkdownParameterPrefix)
    case keywords(MarkdownKeywordPrefix)
}
extension MarkdownBlockPrefix:MarkdownSemanticPrefix
{
    static
    var radius:Int { 4 }

    init?(from elements:__shared [MarkdownInline.Block])
    {
        if      let parameter:MarkdownParameterPrefix = .init(from: elements)
        {
            self = .parameter(parameter)
        }
        else if let keywords:MarkdownKeywordPrefix = .init(from: elements)
        {
            self = .keywords(keywords)
        }
        else
        {
            return nil
        }
    }
}
