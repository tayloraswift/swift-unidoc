import Grammar

extension UCF
{
    /// NominalPattern ::= PathComponents ( '&' PathComponents ) *
    /// PathComponents ::= PathComponent ( '.' PathComponent ) *
    enum NominalPatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        typealias Construction = [[(Range<Location>, [UCF.TypePattern])]]

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> Construction where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            try input.parse(as: Pattern.Join<Pattern.Join<PathComponent,
                    UnicodeEncoding<Location, Terminal>.Period,
                    Construction.Element>,
                Pattern.Pad<
                    UnicodeEncoding<Location, Terminal>.Ampersand,
                    UnicodeEncoding<Location, Terminal>.Space>,
                Construction>.self)
        }
    }
}
