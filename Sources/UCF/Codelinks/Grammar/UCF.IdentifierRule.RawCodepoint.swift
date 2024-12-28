import Grammar

extension UCF.IdentifierRule
{
    /// Matches any terminal that is not a backtick (`` ` ``).
    enum RawCodepoint:TerminalRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar
        typealias Construction = Void

        static func parse(terminal:Terminal) -> Void?
        {
            terminal != "`" ? () : nil
        }
    }
}
