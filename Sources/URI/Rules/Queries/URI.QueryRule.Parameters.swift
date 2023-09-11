import Grammar

extension URI.QueryRule
{
    /// A parsing rule that matches zero or more ``QueryComponentRule``s separated by
    /// ``QuerySeparatorRule``s.
    enum Parameters
    {
    }
}
extension URI.QueryRule.Parameters:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) -> [URI.Query.Parameter]
        where Source:Collection<UInt8>, Source.Index == Location
    {
        input.parse(as: Pattern.Join<
            URI.QueryComponentRule<Location>,
            URI.QuerySeparatorRule<Location>,
            [URI.Query.Parameter]>?.self) ?? []
    }
}
