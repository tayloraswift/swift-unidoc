import Grammar

extension URI
{
    /// A parsing rule that matches an absolute path, such as `/foo/bar/baz`.
    /// Parsing a relative path with this rule will throw an error.
    enum AbsolutePathRule<Location>
    {
    }
}
extension URI.AbsolutePathRule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> URI.Path
        where Source:Collection<UInt8>, Source.Index == Location
    {
        let components:[URI.Path.Component] = try input.parse(
            as: Pattern.Reduce<URI.PathElementRule<Location>, [URI.Path.Component]>.self)
        //  special case for root
        return components == [.empty] ? [] : .init(components: components)
    }
}
