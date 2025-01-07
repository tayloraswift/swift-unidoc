import Grammar

extension UCF.DisambiguatorRule
{
    /// Clauses ::= Space '[' Clause ( ',' Clause ) * ']'
    ///
    /// Note that the leading whitespace is considered part of the filter.
    enum Clauses:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> [(String, String?)] where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            try input.parse(as: UCF.SpaceRule.self)

            //  No padding around structural characters; ``DisambiguationClauseRule`` already
            //  trims whitespace.
            try input.parse(as: UnicodeEncoding<Location, Terminal>.BracketLeft.self)
            let clauses:[(String, String?)] = try input.parse(
                as: Pattern.Join<Clause, UnicodeEncoding<Location, Terminal>.Comma, [_]>.self)
            try input.parse(as: UnicodeEncoding<Location, Terminal>.BracketRight.self)
            return clauses
        }
    }
}
