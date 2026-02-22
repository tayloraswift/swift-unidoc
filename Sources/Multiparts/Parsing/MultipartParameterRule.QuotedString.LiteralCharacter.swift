import Grammar

extension MultipartParameterRule.QuotedString {
    enum LiteralCharacter: TerminalRule {
        typealias Terminal = UInt8
        typealias Construction = Void

        static func parse(terminal: UInt8) -> Void? {
            switch terminal {
            case    0x09,   // '\t'
                0x20 ... 0x21,
                0x23 ... 0x5b,
                0x5d ... 0x7e,
                0x80 ... 0xff:
                ()
            default:
                nil
            }
        }
    }
}
