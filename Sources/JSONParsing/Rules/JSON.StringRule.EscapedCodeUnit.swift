import Grammar

extension JSON.StringRule
{
    /// Matches an ASCII character (besides `u`) that is allowed to
    /// appear immediately after a backslash (`\`) in a string literal.
    ///
    /// The following are valid escape characters: `\`, `"`, `/`, `b`, `f`, `n`, `r`, `t`.
    enum EscapedCodeUnit:TerminalRule
    {
        typealias Terminal = UInt8
        typealias Construction = Unicode.Scalar

        static
        func parse(terminal:UInt8) -> Unicode.Scalar?
        {
            switch terminal
            {
            // '\\', '\"', '\/'
            case 0x5c, 0x22, 0x2f:
                        return .init(terminal)
            case 0x62:  return "\u{08}" // '\b'
            case 0x66:  return "\u{0C}" // '\f'
            case 0x6e:  return "\u{0A}" // '\n'
            case 0x72:  return "\u{0D}" // '\r'
            case 0x74:  return "\u{09}" // '\t'
            default:    return nil
            }
        }
    }
}
