import Grammar

extension URI.FragmentRule
{
    /// A parsing rule that matches a UTF-8 code unit that is allowed to appear inline in a
    /// fragment. This is every code unit except for `%`.
    enum UnencodedByte
    {
    }
}
extension URI.FragmentRule.UnencodedByte:TerminalRule
{
    typealias Terminal = UInt8
    typealias Construction = Void

    static
    func parse(terminal:Terminal) -> Void?
    {
        switch terminal
        {
        case 0x25:  nil // '%'
        default:    ()
        }
    }
}
