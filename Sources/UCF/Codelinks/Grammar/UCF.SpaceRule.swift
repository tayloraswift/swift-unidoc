import Grammar

extension UCF
{
    /// Space ::= \s + | '-'
    enum SpaceRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> Void where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            if  case ()? = input.parse(as: UnicodeEncoding<Location, Terminal>.Space?.self)
            {
                input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)
            }
            else
            {
                try input.parse(as: UnicodeEncoding<Location, Terminal>.Hyphen.self)
            }
        }
    }
}
