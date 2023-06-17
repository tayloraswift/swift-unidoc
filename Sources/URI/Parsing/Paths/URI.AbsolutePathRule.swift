import Grammar

extension URI
{
    /// A parsing rule that matches an absolute path, such as
    /// `/foo/bar/baz`. Parsing a relative path with this
    /// rule will throw an error.
    ///
    /// Parsing a root expression (`/`) with this rule produces
    /// a path with a single, nil path vector.
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
        //  '//foo/bar/.\bax.qux/..//baz./.Foo/%2E%2E//' becomes
        // ['', 'foo', 'bar', < None >, 'bax.qux', < Self >, '', 'baz.bar', '.Foo', '..', '', '']
        //
        //  the first slash '/' does not generate an empty component.
        //  this is the uri we percieve as the uri entered by the user, even
        //  if their slash ('/' vs '\') or percent-encoding scheme is different.
        .init(components: try input.parse(
            as: Pattern.Reduce<URI.PathElementRule<Location>, [URI.Path.Component]>.self))
    }
}
