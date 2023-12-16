import Grammar

extension UA
{
    enum WhitespaceRule
    {
    }
}
extension UA.WhitespaceRule:TerminalRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8
    typealias Construction = Void

    static
    func parse(terminal:UInt8) -> Void?
    {
        switch terminal
        {
        //    ' '  '\t'  '\r'  '\n'
        case 0x20, 0x09, 0x0d, 0x0a:
            ()
        default:
            nil
        }
    }
}
