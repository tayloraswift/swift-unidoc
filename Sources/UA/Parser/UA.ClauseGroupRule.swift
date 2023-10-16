import Grammar

extension UA
{
    struct ClauseGroupRule
    {
    }
}
extension UA.ClauseGroupRule:ParsingRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> [String]
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: UnicodeEncoding.ParenthesisLeft.self)

        let clauses:[String] = try input.parse(
            as: Pattern.Join<UA.ClauseRule, Separator, [String]>.self)

        try input.parse(as: UnicodeEncoding.ParenthesisRight.self)

        return clauses
    }
}
