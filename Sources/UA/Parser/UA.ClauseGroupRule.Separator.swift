import Grammar

extension UA.ClauseGroupRule
{
    struct Separator
    {
    }
}
extension UA.ClauseGroupRule.Separator:ParsingRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> Void
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: UnicodeEncoding.Semicolon.self)
            input.parse(as: UA.WhitespaceRule.self, in: Void.self)
    }
}
