import HTML

extension MarkdownElementContext
{
    enum Section:String, Equatable, Hashable, Sendable
    {
        case parameters
        case returns
        case `throws`
    }
}
extension MarkdownElementContext.Section:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .parameters:   return "Parameters"
        case .returns:      return "Returns"
        case .throws:       return "Throws"
        }
    }
}
