extension CodelinkResolver
{
    /// Resolves codelinks with case-sensitivity.
    enum Exact
    {
    }
}
extension CodelinkResolver.Exact:CodelinkCollation
{
    static
    func collate(_ path:LexicalPath) -> String
    {
        path.joined(separator: ".")
    }
}
