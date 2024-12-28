import Grammar

extension UCF.TypePatternRule
{
    enum PostfixOperatorCodepoint:TerminalRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        typealias Construction = UCF.TypeOperator

        static func parse(terminal:Terminal) -> UCF.TypeOperator?
        {
            switch terminal
            {
            case "?":   return .question
            case "!":   return .exclamation
            default:    return nil
            }
        }
    }
}
