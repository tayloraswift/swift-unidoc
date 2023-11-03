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
        var i:String.Index = string.indices.first
        else
        {
            return nil
        }

        if  string[i] == "/"
        {
            self.init(base: .qualified)
            i = string.index(after: i)
        }
        else
        {
            self.init(base: .relative)
        }

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
    public
    init(v3 link:CodelinkV3)
    {
        var path:Path
        if  let scope:CodelinkV3.Scope = link.scope
        {
            path = .init(components: scope.components.prefix)
            path.components.append(scope.components.last.unencased)

            path.fold = path.components.endIndex

            path.components += link.path.components.prefix
            path.components.append(link.path.components.last.unencased)
        }
        else
        {
            path = .init(components: link.path.components.prefix)
            path.components.append(link.path.components.last.unencased)
        }

        if  let hash:FNV24 = link.hash
        {
            self.init(base: .qualified, path: path, suffix: .hash(hash))
        }
        else if
            let filter:CodelinkV3.Filter = link.filter
        {
            let suffix:Suffix? =
            switch filter
            {
            case .actor:                .filter(.actor)
            case .associatedtype:       .filter(.associatedtype)
            case .case:                 .filter(.case)
            case .class:                .filter(.class)
            case .enum:                 .filter(.enum)
            case .func(.default):       .filter(.func)
            case .func(.class):         .filter(.class_func)
            case .func(.global):        .legacy(.init(filter: .func))
            case .func(.instance):      .legacy(.init(filter: .method))
            case .func(.static):        .filter(.static_func)
            case .func(.type):          .legacy(.init(filter: .type_method))
            case .macro:                .filter(.macro)
            case .module:               nil
            case .protocol:             .filter(.protocol)
            case .struct:               .filter(.struct)
            case .subscript(.class):    .filter(.class_subscript)
            case .subscript(.instance): .filter(.subscript)
            case .subscript(.static):   .filter(.static_subscript)
            case .subscript(.type):     .legacy(.init(filter: .type_subscript))
            case .typealias:            .filter(.typealias)
            case .var(.default):        .filter(.var)
            case .var(.class):          .filter(.class_var)
            case .var(.global):         .legacy(.init(filter: .var))
            case .var(.instance):       .legacy(.init(filter: .property))
            case .var(.static):         .filter(.static_var)
            case .var(.type):           .legacy(.init(filter: .type_property))
            }

            self.init(base: .qualified, path: path, suffix: suffix)
        }
        else
        {
            self.init(base: .qualified, path: path)
        }
    }
}
