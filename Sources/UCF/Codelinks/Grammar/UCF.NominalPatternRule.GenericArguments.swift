import Grammar

extension UCF.NominalPatternRule
{
    /// GenericArguments ::= '<' \s * TypePattern ( \s * ',' \s * TypePattern ) * \s * '>'
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
            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)
            let types:[UCF.TypePattern] = try input.parse(as: Pattern.Join<UCF.TypePatternRule,
                Pattern.Pad<
                    UnicodeEncoding<Location, Terminal>.Comma,
                    UnicodeEncoding<Location, Terminal>.Space>,
                [UCF.TypePattern]>.self)
            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)
            try input.parse(as: UnicodeEncoding<Location, Terminal>.AngleRight.self)
            return types
        }
    }
}
