import Grammar

extension URI
{
    /// A parsing rule that matches an absolute URI, such as
    /// `/foo/bar/baz?a=x&b=y`. Parsing a relative URI with this
    /// rule will throw an error.
    ///
    /// Parsing a root expression (`/`) with this rule produces
    /// a URI with a single, nil path vector.
    enum Rule<Location>
    {
    }
}
extension URI.Rule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> URI
        where Source:Collection<UInt8>, Source.Index == Location
    {
        let path:URI.Path = try input.parse(as: URI.AbsolutePathRule<Location>.self)
        let query:URI.Query? = input.parse(as: URI.QueryRule<Location>?.self)
        return .init(path: path, query: query)
    }
}
