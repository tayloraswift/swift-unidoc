import Grammar

extension URI
{
    /// A parsing rule that matches a ``PathSeparatorRule`` followed by a
    /// ``PathComponentRule``, whose construction is the construction of the
    /// ``PathComponentRule``.
    public
    enum PathElementRule<Location>
    {
    }
}
extension URI.PathElementRule:ParsingRule
{
    public
    typealias Terminal = UInt8

    @inlinable public static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> URI.Path.Component
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: URI.PathSeparatorRule<Location>.self)
        return try input.parse(as: URI.PathComponentRule<Location>.self)
    }
}
