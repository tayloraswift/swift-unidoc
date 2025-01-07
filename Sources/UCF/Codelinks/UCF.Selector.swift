import FNV1

extension UCF
{
    @frozen public
    struct Selector:Equatable, Hashable, Sendable
    {
        public
        let base:Base
        public
        var path:Path
        public
        var suffix:Suffix?

        @inlinable public
        init(base:Base, path:Path = .init(), suffix:Suffix? = nil)
        {
            self.base = base
            self.path = path
            self.suffix = suffix
        }
    }
}

extension UCF.Selector:CustomStringConvertible
{
    public
    var description:String
    {
        var string:String = ""

        for (i, component):(Int, String) in zip(
            self.path.components.indices,
            self.path.components)
        {
            if  self.path.components.startIndex != i
            {
                string += self.path.fold == i ? "/" : "."
            }
            else if case .qualified = self.base
            {
                string += "/"
            }

            string += component
        }

        if  case .trailingParentheses? = self.path.seal
        {
            string += "()"
        }

        switch self.suffix
        {
        case nil:
            return string

        case .unidoc(let filter)?:
            if  let signature:UCF.SignatureFilter = filter.signature
            {
                string.append(" ")
                string.append(signature.formatted(spaces: true))
            }
            if !filter.conditions.isEmpty
            {
                string.append(" [")
                var first:Bool = true
                for condition:UCF.ConditionFilter in filter.conditions
                {
                    if  first
                    {
                        first = false
                    }
                    else
                    {
                        string.append(", ")
                    }

                    string.append("\(condition.keywords)")

                    if !condition.expected
                    {
                        string.append(": false")
                    }
                }
                string.append("]")
            }
            return string

        case .hash(let hash)?:
            return "\(string) [\(hash)]"

        case .legacy(let filter, nil):
            return "\(string)-swift.\(filter.rawValue)"

        case .legacy(let filter, let hash?):
            return "\(string)-swift.\(filter.rawValue)-\(hash)"
        }
    }
}
extension UCF.Selector:LosslessStringConvertible
{
    public
    init?(_ string:String)
    {
        self.init(string[...])
    }

    public
    init?(_ string:Substring)
    {
        guard
        let i:String.Index = string.indices.first
        else
        {
            return nil
        }

        //  Trim trailing slashes.
        var j:String.Index = string.endIndex
        while true
        {
            let k:String.Index = string.index(before: j)

            guard case "/" = string[k]
            else
            {
                break
            }

            if  k == i
            {
                //  String only contains slashes.
                return nil
            }

            j = k
        }

        if  string[i] != "/"
        {
            self.init(base: .relative, parsing: string[i ..< j])
            return
        }

        var path:Path = .init()
        //  Special case for bare operator references:
        if  let sole:PathComponent = .parse(string.unicodeScalars[i ..< j]),
            j == sole.range.upperBound
        {
            path.append(sole)
            self.init(base: .relative, path: path)
        }
        else
        {
            self.init(base: .qualified, parsing: string[string.index(after: i) ..< j])
        }
    }
}
extension UCF.Selector
{
    private
    init?(base:Base, parsing string:Substring)
    {
        self.init(base: base)

        var i:String.Index = string.startIndex
        while let next:PathComponent = .parse(string.unicodeScalars[i...])
        {
            self.path.append(next)

            let j:String.Index = next.range.upperBound
            if  j < string.endIndex
            {
                i = string.index(after: j)
            }
            else
            {
                return
            }

            switch string[j]
            {
            case "/":
                self.path.fold = self.path.components.endIndex
                continue

            case ".":
                continue

            case " ":
                //  The space is part of the disambiguator, so we must slice from `j`, not `i`
                if  let suffix:Suffix = .parse(unidoc: string[j...])
                {
                    self.suffix = suffix
                    return
                }
                else
                {
                    return nil
                }

            case "-":
                //  Parse a legacy DocC disambiguation suffix.
                if  let slash:String.Index = string[i...].firstIndex(of: "/")
                {
                    //  This is an interior path component, so the disambiguator is
                    //  meaningless. XCode generates these for historical reasons that
                    //  are irrelevant and indistinguishable from a bug to us.
                    i = string.index(after: slash)

                    self.path.fold = self.path.components.endIndex
                    continue
                }
                //  The hyphen is part of the disambiguator, so we must slice from `j`, not `i`
                else if
                    let suffix:Suffix = .parse(legacy: string[j...])
                {
                    self.suffix = suffix
                    return
                }
                else
                {
                    return nil
                }

            case _:
                return nil
            }
        }

        return nil
    }
}
