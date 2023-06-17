import Grammar

extension URI
{
    /// A parsing rule that matches a URI path component, which can be empty,
    /// a [`'.'`](), or a [`'..'`](). The dotted components will not be
    /// considered “special” if they are percent-encoded.
    public
    enum PathComponentRule<Location>
    {
    }
}
extension URI.PathComponentRule:ParsingRule
{
    public
    typealias Terminal = UInt8

    @inlinable public static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> URI.Path.Component
        where Source:Collection<UInt8>, Source.Index == Location
    {
        switch try input.parse(as: PercentEncodedStringRule<UnencodedByte>.self)
        {
        case (".",  true):  return .empty
        case ("..", true):  return .pop
        case (let next, _): return .push(next)
        }
    }
}
