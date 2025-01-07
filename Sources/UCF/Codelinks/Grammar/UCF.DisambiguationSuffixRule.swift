import Grammar

extension UCF
{
    /// DisambiguationSuffix ::= SignatureSuffix Clauses ? | Clauses
    ///
    /// Note that the leading whitespace is considered part of the disambiguator.
    enum DisambiguationSuffixRule:ParsingRule
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
            if  let clauses:[(String, String?)] = input.parse(as: DisambiguatorRule.Clauses?.self)
            {
                return (nil, clauses)
            }

            let signature:SignaturePattern = try input.parse(as: SignatureSuffixRule.self)
            return (signature, input.parse(as: DisambiguatorRule.Clauses?.self) ?? [])
        }
    }
}
