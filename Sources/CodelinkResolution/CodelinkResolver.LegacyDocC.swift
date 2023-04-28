extension CodelinkResolver
{
    /// Resolves codelinks without case-sensitivity.
    enum LegacyDocC
    {
    }
}
extension CodelinkResolver.LegacyDocC:CodelinkCollation
{
    static
    func collate(_ path:some BidirectionalCollection<String>) -> String
    {
        path.lazy.map { $0.lowercased() } .joined(separator: "/")
    }
}
