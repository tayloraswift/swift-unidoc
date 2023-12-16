import Grammar

extension URI
{
    /// A parsing rule that matches a path separator character
    /// (`/` or `\`).
    enum PathSeparatorRule<Location>
    {
    }
}
extension URI.PathSeparatorRule:TerminalRule
{
    typealias Terminal = UInt8
    typealias Construction = Void

    static
    func parse(terminal:Terminal) -> Void?
    {
        switch terminal
        {
        //    '/'   '\'
        case 0x2f, 0x5c: ()
        default: nil
        }
    }
}
