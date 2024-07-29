extension UCF.Selector
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        /// The individual components of this path.
        public
        var components:[String]
        /// The index of the first visible component in this path.
        public
        var fold:Int

        @inlinable public
        init(components:[String] = [], fold:Int = 0)
        {
            self.components = components
            self.fold = fold
        }
    }
}
extension UCF.Selector.Path
{
    @inlinable public
    var visible:ArraySlice<String>
    {
        self.components[self.fold...]
    }
}
extension UCF.Selector.Path
{
    /// Attempts to extend this path by parsing the given string, returning nil if the string
    /// does not begin with a valid path component. This method only changes the path if the
    /// parsing succeeds.
    mutating
    func extend(parsing string:Substring.UnicodeScalarView) -> String.Index?
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

        if  j < string.endIndex, string[j] == "("
        {
            let k:String.Index = string.index(after: j)

            switch string[k...].firstIndex(of: ")")
            {
            case nil:
                return nil

            case k?:
                //  Special case: ignore empty trailing parentheses
                self.components.append(String.init(string[i ..< j]))
                return string.index(after: k)

            case let k?:
                j = string.index(after: k)
            }
        }

        self.components.append(String.init(string[i ..< j]))
        return j
    }
}
