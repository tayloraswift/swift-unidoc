import HTML

extension MarkdownElementContext
{
    /// A section context, which typically renders as an `section` HTML element.
    /// The most famous section context is probably ``parameters``, but some
    /// markdown “asides”, like ``returns`` and ``throws`` are also considered
    /// section contexts. Semantic processing always reorders section contexts to
    /// the top of the document.
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