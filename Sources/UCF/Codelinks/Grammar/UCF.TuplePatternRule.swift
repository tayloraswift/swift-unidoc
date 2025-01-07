import Grammar

extension UCF
{
    /// TuplePattern ::= '(' \s * ( TypePattern ( \s * ',' TypePattern ) * ) ? \s * ')'
    enum TuplePatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> [TypePattern] where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            try input.parse(as: UnicodeEncoding<Location, Terminal>.ParenthesisLeft.self)
            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)

            /// This is not a Join, as it is legal for there to be no elements in the tuple.
            var types:[TypePattern] = []

            if  let type:TypePattern = input.parse(as: TypePatternRule?.self)
            {
                types.append(type)

                while case ()? = input.parse(
                    as: Pattern.Pad<
                        UnicodeEncoding<Location, Terminal>.Comma,
                        UnicodeEncoding<Location, Terminal>.Space>?.self)
                {
                    types.append(try input.parse(as: TypePatternRule.self))
                }
            }

            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)
            try input.parse(as: UnicodeEncoding<Location, Terminal>.ParenthesisRight.self)

            return types
        }
    }
}
