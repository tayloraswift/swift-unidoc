import Grammar

extension UCF
{
    /// TypeElement ::= '~' ? TypeOperand PostfixOperator *
    enum TypeElementRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Source>(
            _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> TypeElement
            where Source:Collection<Terminal>, Source.Index == Location
        {
            let sigil:TypeSigil?
            if  case ()? = input.parse(as: UnicodeEncoding<Location, Terminal>.Tilde?.self)
            {
                sigil = .tilde
            }
            else
            {
                sigil = nil
            }

            let operand:TypeOperand = try input.parse(as: TypeOperandRule.self)
            let suffix:[TypeOperator] = input.parse(as: PostfixOperator.self, in: [_].self)

            if  suffix.isEmpty,
                case nil = sigil,
                case .single(let parenthesized?) = operand,
                let inhabitant:TypeElement = parenthesized.inhabitant
            {
                //  If this is a bare parenthesized operand with no operators, unwrap it.
                return inhabitant
            }
            else
            {
                return .init(prefix: sigil, operand: operand, suffix: suffix)
            }
        }
    }
}
