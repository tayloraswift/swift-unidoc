import Grammar

extension MultipartTokenRule
{
    // https://httpwg.org/specs/rfc9110.html#tokens
    enum CodeUnit:TerminalRule
    {
        typealias Terminal = UInt8
        typealias Construction = Void

        static
        func parse(terminal:UInt8) -> Void?
        {
            switch terminal
            {
            case    0x30 ... 0x39,  // [0-9]
                    0x41 ... 0x5a,  // [A-Z]
                    0x61 ... 0x7a,  // [a-z]
                    0x21,   // !
                    0x23,   // #
                    0x24,   // $
                    0x25,   // %
                    0x26,   // &
                    0x27,   // '
                    0x2a,   // *
                    0x2b,   // +
                    0x2d,   // -
                    0x2e,   // .
                    0x5e,   // ^
                    0x5f,   // _
                    0x60,   // `
                    0x7c,   // |
                    0x7e:   // ~
                ()
            default:
                nil
            }
        }
    }
}
