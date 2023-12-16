import Grammar

extension UA.ClauseRule
{
    /// A parsing rule that matches a character that can appear in a UA clause.
    ///
    /// ## Grammar
    ///
    /// ```ebnf
    /// Self = ^ ( ';' | '(' | ')' )
    /// ```
    enum CodeUnit
    {
    }
}
extension UA.ClauseRule.CodeUnit:TerminalRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8
    typealias Construction = Void

    static
    func parse(terminal:UInt8) -> Void?
    {
        switch terminal
        {
        //    ';'   '('   ')'
        case 0x3b, 0x28, 0x29:
            nil
        default:
            ()
        }
    }
}
