import Codelinks

extension Codelink
{
    /// Resolves codelinks without case-sensitivity.
    enum LegacyDocC
    {
    }
}
extension Codelink.LegacyDocC:CodelinkCollation
{
    static
    func collate(_ path:some BidirectionalCollection<String>) -> String
    {
        path.lazy.map { $0.lowercased() } .joined(separator: "/")
    }
}
