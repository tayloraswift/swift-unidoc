import Grammar

extension URI
{
    /// A parsing rule that matches a query component, such as `a=b`,
    /// whose construction is the key-value pair making up the component.
    enum QueryComponentRule<Location>
    {
    }
}
extension URI.QueryComponentRule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(_ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> URI.Query.Parameter
        where Source:Collection<UInt8>, Source.Index == Location
    {
        let (key, _):(String, Bool) =
            try input.parse(as: PercentEncodedStringRule<UnencodedByte>.self)
        try input.parse(as: UnicodeEncoding<Location, UInt8>.Equals.self)
        let (value, _):(String, Bool) =
            try input.parse(as: PercentEncodedStringRule<UnencodedByte>.self)
        return (key, value)
    }
}
