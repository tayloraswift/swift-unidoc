extension URI
{
    @frozen public
    struct QueryEncodedForm:Sendable
    {
        public
        var parameters:[Query.Parameter]

        private
        init(_ parameters:[Query.Parameter])
        {
            self.parameters = parameters
        }
    }
}
extension URI.QueryEncodedForm
{
    @inlinable public
    var query:URI.Query { .init(self.parameters) }
}
extension URI.QueryEncodedForm
{
    /// FIXME: This is hideously inefficient. We probably want to use a custom parser
    /// that can transform the `+` characters without copying the entire string into an array!
    private static
    func parse(utf8:consuming [UInt8]) throws -> Self
    {
        for i:Int in utf8.indices
        {
            if  utf8[i] == 0x2B
            {
                utf8[i] = 0x20
            }
        }

        return .init(try URI.QueryRule<Int>.Parameters.parse(utf8))
    }

    /// Parses query parameters from UTF-8 text. This parser does not expect a leading
    /// question mark (`?`).
    public static
    func parse(parameters:ArraySlice<UInt8>) throws -> Self
    {
        try .parse(utf8: [UInt8].init(parameters))
    }

    public static
    func parse(parameters:Substring) throws -> Self
    {
        try .parse(utf8: [UInt8].init(parameters.utf8))
    }
}
