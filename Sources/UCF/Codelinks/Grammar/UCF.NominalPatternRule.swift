import Grammar

extension UCF
{
    /// NominalPattern ::= PathComponent ( '.' PathComponent ) *
    enum NominalPatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar
        typealias Construction = [(Range<Location>, [UCF.TypePattern])]

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> Construction where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            try input.parse(as: Pattern.Join<PathComponent,
                UnicodeEncoding<Location, Terminal>.Period,
                Construction>.self)
        }
    }
}
