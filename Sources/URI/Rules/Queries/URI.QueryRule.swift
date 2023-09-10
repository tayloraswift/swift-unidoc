import Grammar

extension URI
{
    /// A parsing rule that matches a leading question mark (`?`),
    /// followed by zero or more ``Parameters``.
    enum QueryRule<Location>
    {
    }
}
extension URI.QueryRule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> URI.Query
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: UnicodeEncoding<Location, UInt8>.Question.self)
        return .init(try input.parse(as: Parameters.self))
    }
}
