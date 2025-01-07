import Grammar

extension UCF.DisambiguatorRule.Clause
{
    /// AlphanumericWord ::= Space ? [0-9A-Za-z] + Space ?
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
            input.parse(as: UCF.SpaceRule?.self)

            let start:Location = input.index
            try input.parse(as: AlphanumericCodepoint.self)
            input.parse(as: AlphanumericCodepoint.self, in: Void.self)
            let end:Location = input.index

            input.parse(as: UCF.SpaceRule?.self)

            return start ..< end
        }
    }
}
