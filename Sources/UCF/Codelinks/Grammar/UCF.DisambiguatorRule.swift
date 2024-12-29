import Grammar

extension UCF
{
    /// Disambiguator ::= ' ' + SignaturePattern Clauses ? | Clauses
    ///
    /// Note that the leading whitespace is considered part of the disambiguator.
    enum DisambiguatorRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar
        typealias Construction = (SignaturePattern?, [(String, String?)])

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> Construction where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            if  let clauses:[(String, String?)] = input.parse(as: Clauses?.self)
            {
                return (nil, clauses)
            }

            try input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self)
                input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)

            let signature:SignaturePattern = try input.parse(as: SignaturePatternRule.self)
            return (signature, input.parse(as: Clauses?.self) ?? [])
        }
    }
}
