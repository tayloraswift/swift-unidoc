import Grammar

// https://httpwg.org/specs/rfc9110.html#whitespace
enum HorizontalWhitespaceRule<Location>: TerminalRule {
    typealias Terminal = UInt8
    typealias Construction = Void

    static func parse(terminal: UInt8) -> Void? {
        switch terminal {
        case 0x09, 0x20: // '\t', ' '
            ()
        default:
            nil
        }
    }
}
