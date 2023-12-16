import Grammar

extension URI.QueryComponentRule
{
    /// A parsing rule that matches a UTF-8 code unit that is allowed to
    /// appear inline in the key or value of a query component.
    /// This is every code unit except for `%`, `&`, `;`, `=`, and `#`.
    enum UnencodedByte
    {
    }
}
extension URI.QueryComponentRule.UnencodedByte:TerminalRule
{
    typealias Terminal = UInt8
    typealias Construction = Void

    static
    func parse(terminal:Terminal) -> Void?
    {
        switch terminal
        {
        //    '%'   '&'   ';'   '='   '#'
        case 0x25, 0x26, 0x3b, 0x3d, 0x23:
            nil
        default:
            ()
        }
    }
}
