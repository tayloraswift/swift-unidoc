import Grammar

extension JSON.NumberRule
{
    /// Matches an ASCII `+` or `-` sign.
    enum PlusOrMinus:TerminalRule
    {
        typealias Terminal = UInt8
        typealias Construction = FloatingPointSign

        static
        func parse(terminal:UInt8) -> FloatingPointSign?
        {
            switch terminal
            {
            case 0x2b:  return .plus
            case 0x2d:  return .minus
            default:    return nil
            }
        }
    }
}
