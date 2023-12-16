import Grammar

extension URI
{
    /// A parsing rule that matches a query separator character
    /// (`&` or `;`).
    enum QuerySeparatorRule<Location>
    {
    }
}
extension URI.QuerySeparatorRule:TerminalRule
{
    typealias Terminal = UInt8
    typealias Construction = Void

    static
    func parse(terminal:Terminal) -> Void?
    {
        switch terminal
        {
        //    '&'   ';'
        case 0x26, 0x3b:
            ()
        default:
            nil
        }
    }
}
