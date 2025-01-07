import Grammar

extension UCF
{
    /// BracketPattern ::= '[' TypePattern ( \s * ':' \s * TypePattern ) ? ']'
    enum BracketPatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        typealias Construction = (TypePattern, TypePattern?)

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> Construction where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            try input.parse(as: UnicodeEncoding<Location, Terminal>.BracketLeft.self)

            let first:TypePattern = try input.parse(as: TypePatternRule.self)
            let value:TypePattern?

            if  case ()? = input.parse(as: Pattern.Pad<
                    UnicodeEncoding<Location, Terminal>.Colon,
                    UnicodeEncoding<Location, Terminal>.Space>?.self)
            {
                value = try input.parse(as: TypePatternRule.self)
            }
            else
            {
                value = nil
            }

            try input.parse(as: UnicodeEncoding<Location, Terminal>.BracketRight.self)

            return (first, value)
        }
    }
}
