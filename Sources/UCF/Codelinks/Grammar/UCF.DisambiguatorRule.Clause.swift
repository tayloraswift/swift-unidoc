import Grammar

extension UCF.DisambiguatorRule
{
    /// Clause ::= AlphanumericWord + ( ':' AlphanumericWord + ) ?
    enum Clause:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> (String, String?) where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            let label:String = try input.parse(as: AlphanumericWords.self)
            //  No whitespace padding around the colon; ``AlphanumericWords`` already trims.
            if  case ()? = input.parse(as: UnicodeEncoding<Location, Terminal>.Colon?.self)
            {
                return (label, try input.parse(as: AlphanumericWords.self))
            }
            else
            {
                return (label, nil)
            }
        }
    }
}
