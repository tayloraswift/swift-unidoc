import FNV1

@frozen public
struct Codelink:Equatable, Hashable, Sendable
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
extension Codelink:CustomStringConvertible
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

        switch self.suffix
        {
        case nil:
            return string

        case .filter(let filter)?:
            return "\(string) [\(filter)]"

        case .hash(let hash)?:
            return "\(string) [\(hash)]"

        case .legacy(let legacy):
            if  let hash:FNV24 = legacy.hash
            {
                return "\(string)-swift.\(legacy.filter.rawValue)-\(hash)"
            }
            else
            {
                return "\(string)-swift.\(legacy.filter.rawValue)"
            }
        }
    }
}
extension Codelink:LosslessStringConvertible
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
        if  case j? = path.extend(parsing: string.unicodeScalars[i ..< j])
        {
            self.init(base: .relative, path: path)
        }
        else
        {
            self.init(base: .qualified, parsing: string[string.index(after: i) ..< j])
        }
    }
}
extension Codelink
{
    private
    init?(base:Base, parsing string:Substring)
    {
        self.init(base: base)

        var i:String.Index = string.startIndex
        while let j:String.Index = self.path.extend(parsing: string.unicodeScalars[i...])
        {
            guard j < string.endIndex
            else
            {
                return
            }

            i = string.index(after: j)

            switch string[j]
            {
            case "/":
                self.path.fold = self.path.components.endIndex
                continue

            case ".":
                continue

            case " ":
                guard
                let bracket:String.Index = string[i...].firstIndex(of: "[")
                else
                {
                    return nil
                }

                let i:String.Index = string.index(after: bracket)

                guard
                let bracket:String.Index = string[i...].firstIndex(of: "]")
                else
                {
                    return nil
                }

                if  let filter:Filter = .init(string[i ..< bracket])
                {
                    self.suffix = .filter(filter)
                    return
                }
                else if
                    let hash:FNV24 = .init(string[i ..< bracket])
                {
                    self.suffix = .hash(hash)
                    return
                }
                else
                {
                    return nil
                }

            case "-":
                if  let slash:String.Index = string[i...].firstIndex(of: "/")
                {
                    //  This is an interior path component, so the disambiguator is
                    //  meaningless. XCode generates these for historical reasons that
                    //  are irrelevant and indistinguishable from a bug to us.
                    i = string.index(after: slash)

                    self.path.fold = self.path.components.endIndex
                    continue
                }

                //  Parse a legacy DocC disambiguation suffix.
                var filter:Suffix.Legacy.Filter? = nil
                var hash:FNV24? = nil

                while i < string.endIndex
                {
                    if  let k:String.Index = string[i...].firstIndex(of: ".")
                    {
                        guard string[i ..< k] == "swift"
                        else
                        {
                            return nil
                        }

                        let k:String.Index = string.index(after: k)
                        if  let hyphen:String.Index = string[k...].firstIndex(of: "-")
                        {
                            filter = .init(rawValue: string[k ..< hyphen])
                            i = string.index(after: hyphen)
                        }
                        else
                        {
                            filter = .init(rawValue: string[k...])
                            break
                        }

                        if  case nil = filter
                        {
                            return nil
                        }
                    }
                    else
                    {
                        if  let hyphen:String.Index = string[i...].firstIndex(of: "-")
                        {
                            hash = .init(string[i ..< hyphen])
                            i = string.index(after: hyphen)
                        }
                        else
                        {
                            hash = .init(string[i...])
                            break
                        }

                        if  case nil = hash
                        {
                            return nil
                        }
                    }
                }

                if  let filter:Suffix.Legacy.Filter
                {
                    if  case nil = hash,
                        let filter:Filter = .init(legacy: filter)
                    {
                        self.suffix = .filter(filter)
                        return
                    }
                    else
                    {
                        self.suffix = .legacy(.init(filter: filter, hash: hash))
                        return
                    }
                }
                else
                {
                    if  let hash:FNV24
                    {
                        self.suffix = .hash(hash)
                        return
                    }
                    else
                    {
                        return nil
                    }
                }

            case _:
                return nil
            }
        }

        return nil
    }
}
extension Codelink
{
    @inlinable public static
    func equivalent(to doclink:Doclink) -> Self?
    {
        if  doclink.absolute
        {
            return nil
        }

        return .init(doclink.path.joined(separator: "/"))
    }
}
