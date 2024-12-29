import Grammar

extension UCF.DisambiguatorRule.Clause
{
    /// AlphanumericWord ::= ' ' * [0-9A-Za-z] + ' ' *
    enum AlphanumericWord:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> Range<Location> where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)

            let start:Location = input.index
            try input.parse(as: AlphanumericCodepoint.self)
            input.parse(as: AlphanumericCodepoint.self, in: Void.self)
            let end:Location = input.index

            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)

            return start ..< end
        }
    }
}
