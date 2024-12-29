import Grammar

extension UCF.TypePatternRule
{
    /// PostfixOperand ::= NominalPattern | BracketPattern | FunctionPattern
    enum PostfixOperand:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> UCF.TypeOperand where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            if  let composition:[[(Range<Location>, [UCF.TypePattern])]] = input.parse(
                    as: UCF.NominalPatternRule?.self)
            {
                if  let path:[(Range<Location>, [UCF.TypePattern])] = composition.first,
                    composition.count == 1,
                    let (range, generics):(Range<Location>, [UCF.TypePattern]) = path.first,
                    generics.isEmpty,
                    path.count == 1,
                    input.source.index(after: range.lowerBound) == range.upperBound,
                    input[range.lowerBound] == "_"
                {
                    return .single(nil)
                }

                return .nominal(composition)
            }
            else if
                let (first, value):(UCF.TypePattern, UCF.TypePattern?) = input.parse(
                    as: UCF.BracketPatternRule?.self)
            {
                return .bracket(first, value)
            }

            switch try input.parse(as: UCF.FunctionPatternRule.self)
            {
            case (let tuple, nil):
                if  let first:UCF.TypePattern = tuple.first, tuple.count == 1
                {
                    return .single(first)
                }

                return .tuple(tuple)

            case (let tuple, let output?):
                return .closure(tuple, output)
            }
        }
    }
}
