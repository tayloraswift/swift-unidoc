import Grammar

extension UCF
{
    /// TypePattern ::= PostfixOperand PostfixOperator *
    enum TypePatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Source>(
            _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> TypePattern
            where Source:Collection<Terminal>, Source.Index == Location
        {
            let operand:TypeOperand = try input.parse(as: PostfixOperand.self)
            let operators:[TypeOperator] = input.parse(as: PostfixOperator.self, in: [_].self)

            if  operators.isEmpty,
                case .single(let parenthesized?) = operand
            {
                //  If this is a bare parenthesized operand with no operators, unwrap it.
                return parenthesized
            }
            else
            {
                return .init(operand: operand, suffix: operators)
            }
        }
    }
}
