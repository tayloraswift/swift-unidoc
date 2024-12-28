import Grammar

extension UCF.IdentifierRule
{
    /// A parsing rule that matches a codepoint that can begin a Swift identifier.
    enum FirstCodepoint:TerminalRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar
        typealias Construction = Void

        static func parse(terminal:Terminal) -> Void?
        {
            switch terminal
            {
            case    "a" ... "z",
                    "A" ... "Z",
                    "_",
                    "\u{00A8}",
                    "\u{00AA}",
                    "\u{00AD}",
                    "\u{00AF}",
                    "\u{00B2}" ... "\u{00B5}",
                    "\u{00B7}" ... "\u{00BA}",
                    "\u{00BC}" ... "\u{00BE}",
                    "\u{00C0}" ... "\u{00D6}",
                    "\u{00D8}" ... "\u{00F6}",
                    "\u{00F8}" ... "\u{00FF}",
                    "\u{0100}" ... "\u{02FF}",
                    "\u{0370}" ... "\u{167F}",
                    "\u{1681}" ... "\u{180D}",
                    "\u{180F}" ... "\u{1DBF}",
                    "\u{1E00}" ... "\u{1FFF}",
                    "\u{200B}" ... "\u{200D}",
                    "\u{202A}" ... "\u{202E}",
                    "\u{203F}" ... "\u{2040}",
                    "\u{2054}",
                    "\u{2060}" ... "\u{206F}",
                    "\u{2070}" ... "\u{20CF}",
                    "\u{2100}" ... "\u{218F}",
                    "\u{2460}" ... "\u{24FF}",
                    "\u{2776}" ... "\u{2793}",
                    "\u{2C00}" ... "\u{2DFF}",
                    "\u{2E80}" ... "\u{2FFF}",
                    "\u{3004}" ... "\u{3007}",
                    "\u{3021}" ... "\u{302F}",
                    "\u{3031}" ... "\u{303F}",
                    "\u{3040}" ... "\u{D7FF}",
                    "\u{F900}" ... "\u{FD3D}",
                    "\u{FD40}" ... "\u{FDCF}",
                    "\u{FDF0}" ... "\u{FE1F}",
                    "\u{FE30}" ... "\u{FE44}",
                    "\u{FE47}" ... "\u{FFFD}",
                    "\u{10000}" ... "\u{1FFFD}",
                    "\u{20000}" ... "\u{2FFFD}",
                    "\u{30000}" ... "\u{3FFFD}",
                    "\u{40000}" ... "\u{4FFFD}",
                    "\u{50000}" ... "\u{5FFFD}",
                    "\u{60000}" ... "\u{6FFFD}",
                    "\u{70000}" ... "\u{7FFFD}",
                    "\u{80000}" ... "\u{8FFFD}",
                    "\u{90000}" ... "\u{9FFFD}",
                    "\u{A0000}" ... "\u{AFFFD}",
                    "\u{B0000}" ... "\u{BFFFD}",
                    "\u{C0000}" ... "\u{CFFFD}",
                    "\u{D0000}" ... "\u{DFFFD}",
                    "\u{E0000}" ... "\u{EFFFD}":
                return ()

            default:
                return nil
            }
        }
    }
}
