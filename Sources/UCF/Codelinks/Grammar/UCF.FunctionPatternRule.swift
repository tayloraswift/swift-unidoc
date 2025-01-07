import Grammar

extension UCF
{
    /// FunctionPattern ::= TuplePattern ( Arrow TypePattern ) ?
    enum FunctionPatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        typealias Construction = ([TypePattern], TypePattern?)

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> Construction where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            let tuple:[TypePattern] = try input.parse(as: TuplePatternRule.self)

            if  case ()? = input.parse(as: ArrowRule?.self)
            {
                return (tuple, try input.parse(as: TypePatternRule.self))
            }
            else
            {
                return (tuple, nil)
            }
        }
    }
}
