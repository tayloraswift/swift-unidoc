extension UCF.Selector
{
    struct PathComponent
    {
        /// The string indices corresponding to this path component, which may include
        /// additional junk characters not included in the component ``value`` itself.
        let range:Range<String.Index>
        /// The canonical value of this path component. This never includes empty trailing
        /// parentheses.
        let value:String
        /// Indicates if this path component can be followed by any additional path components,
        /// and if non-nil, indicates the reason why.
        let seal:Seal?
    }
}
extension UCF.Selector.PathComponent
{
    static func parse(_ string:Substring.UnicodeScalarView) -> Self?
    {
        guard
        let i:String.Index = string.indices.first
        else
        {
            return nil
        }

        var j:String.Index = string.index(after: i)

        if  let _:IdentifierHead = .init(string[i])
        {
            loop:
            while j < string.endIndex
            {
                switch string[j]
                {
                case    "0" ... "9",
                        "\u{0300}" ... "\u{036F}",
                        "\u{1DC0}" ... "\u{1DFF}",
                        "\u{20D0}" ... "\u{20FF}",
                        "\u{FE20}" ... "\u{FE2F}":
                    j = string.index(after: j)

                case let codepoint:
                    guard
                    let _:IdentifierHead = .init(codepoint)
                    else
                    {
                        break loop
                    }

                    j = string.index(after: j)
                }
            }
        }
        else if
            let _:OperatorHead = .init(string[i])
        {
            loop:
            while j < string.endIndex
            {
                switch string[j]
                {
                case    "\u{0300}" ... "\u{036F}",
                        "\u{1DC0}" ... "\u{1DFF}",
                        "\u{20D0}" ... "\u{20FF}",
                        "\u{FE00}" ... "\u{FE0F}",
                        "\u{FE20}" ... "\u{FE2F}",
                        "\u{E0100}" ... "\u{E01EF}":
                    j = string.index(after: j)

                case let codepoint:
                    guard
                    let _:OperatorHead = .init(codepoint)
                    else
                    {
                        break loop
                    }

                    j = string.index(after: j)
                }
            }
        }
        else
        {
            return nil
        }

        guard j < string.endIndex, string[j] == "("
        else
        {
            return .init(
                range: i ..< j,
                value: String.init(string[i ..< j]),
                seal: nil)
        }

        let k:String.Index = string.index(after: j)

        switch string[k...].firstIndex(of: ")")
        {
        case nil:
            return nil

        case k?:
            //  Special case: ignore empty trailing parentheses
            return .init(
                range: i ..< string.index(after: k),
                value: String.init(string[i ..< j]),
                seal: .trailingParentheses)

        case let k?:
            j = string.index(after: k)
            return .init(
                range: i ..< j,
                value: String.init(string[i ..< j]),
                seal: .trailingArguments)
        }
    }
}
