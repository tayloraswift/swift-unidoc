import Grammar

extension UA
{
    /// A parsing rule that matches a UA clause.
    ///
    /// ## Grammar
    /// ```ebnf
    /// Self = CodeUnit +
    /// ```
    struct ClauseRule
    {
    }
}
extension UA.ClauseRule:ParsingRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> String
        where Source:Collection<UInt8>, Source.Index == Location
    {
        let start:Location = input.index
        try input.parse(as: CodeUnit.self)
            input.parse(as: CodeUnit.self, in: Void.self)
        let end:Location = input.index
        return .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
    }
}
