import Grammar

extension UCF.DisambiguatorRule.Clause
{
    enum AlphanumericCodepoint:TerminalRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar
        typealias Construction = Void

        static func parse(terminal:Terminal) -> Void?
        {
            "0" ... "9" ~= terminal || terminal.properties.isAlphabetic ? () : nil
        }
    }
}
