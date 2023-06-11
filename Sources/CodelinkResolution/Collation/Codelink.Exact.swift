import Codelinks

extension Codelink
{
    /// Resolves codelinks with case-sensitivity.
    enum Exact
    {
    }
}
extension Codelink.Exact:CodelinkCollation
{
    static
    func collate(_ path:some BidirectionalCollection<String>) -> String
    {
        path.joined(separator: ".")
    }
}
