import Grammar

extension UCF.NominalPatternRule
{
    /// GenericArguments ::= '<' TypePattern ( ',' TypePattern ) * '>'
    enum GenericArguments:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> [UCF.TypePattern] where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            try input.parse(as: UnicodeEncoding<Location, Terminal>.AngleLeft.self)
            let types:[UCF.TypePattern] = try input.parse(as: Pattern.Join<UCF.TypePatternRule,
                UnicodeEncoding<Location, Terminal>.Comma,
                [UCF.TypePattern]>.self)
            try input.parse(as: UnicodeEncoding<Location, Terminal>.AngleRight.self)
            return types
        }
    }
}
