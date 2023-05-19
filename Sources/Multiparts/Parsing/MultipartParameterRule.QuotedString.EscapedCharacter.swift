import Grammar

extension MultipartParameterRule.QuotedString
{
    enum EscapedCharacter:TerminalRule
    {
        typealias Terminal = UInt8
        typealias Construction = Unicode.Scalar

        static
        func parse(terminal:UInt8) -> Unicode.Scalar?
        {
            switch terminal
            {
            case    0x09,           // '\t'
                    0x20 ... 0x7e,  // ' ', VCHAR
                    0x80 ... 0xff:
                return .init(terminal)
            default:
                return nil
            }
        }
    }
}
