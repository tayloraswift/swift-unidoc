import Grammar

extension URI.PathComponentRule
{
    /// A parsing rule that matches a UTF-8 code unit that is allowed to
    /// appear inline in a path component. This is every code unit except for
    /// `%`, `/`, `\`, `?`, and `#`.
    public
    enum UnencodedByte
    {
    }
}
extension URI.PathComponentRule.UnencodedByte:TerminalRule
{
    public
    typealias Terminal = UInt8
    public
    typealias Construction = Void

    @inlinable public static
    func parse(terminal:UInt8) -> Void?
    {
        switch terminal
        {
        //    '%',  '/',  '\',  '?',  '#'
        case 0x25, 0x2f, 0x5c, 0x3f, 0x23:
            return nil
        default:
            return ()
        }
    }
}
