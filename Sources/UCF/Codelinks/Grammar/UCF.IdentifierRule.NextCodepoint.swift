import Grammar

extension UCF.IdentifierRule
{
    /// A parsing rule that matches a codepoint that can occur in a Swift identifier, as long
    /// as it is not the first codepoint.
    enum NextCodepoint:TerminalRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar
        typealias Construction = Void

        static func parse(terminal:Terminal) -> Void?
        {
            switch terminal
            {
            case    "0" ... "9",
                    "\u{0300}" ... "\u{036F}",
                    "\u{1DC0}" ... "\u{1DFF}",
                    "\u{20D0}" ... "\u{20FF}",
                    "\u{FE20}" ... "\u{FE2F}":
                return ()

            default:
                return UCF.IdentifierRule.FirstCodepoint.parse(terminal: terminal)
            }
        }
    }
}
