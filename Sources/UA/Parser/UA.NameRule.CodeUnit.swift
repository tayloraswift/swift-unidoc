import Grammar

extension UA.NameRule
{
    enum CodeUnit
    {
    }
}
extension UA.NameRule.CodeUnit:TerminalRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8
    typealias Construction = Void

    static
    func parse(terminal:UInt8) -> Void?
    {
        switch terminal
        {
        case    0x30 ... 0x39,  //  '0' ... '9'
                0x41 ... 0x5a,  //  'A' ... 'Z'
                0x61 ... 0x7a,  //  'a' ... 'z'
                0x21,           //  '!'
                0x23,           //  '#'
                0x24,           //  '$'
                0x26,           //  '&'
                0x2a,           //  '*'
                0x2b,           //  '+'
                0x2d,           //  '-'
                0x2e,           //  '.'
                0x3a,           //  ':'
                0x3f,           //  '?'
                0x40,           //  '@'
                0x5f,           //  '_'
                0x7e:           //  '~'
            ()
        default:
            nil
        }
    }
}
