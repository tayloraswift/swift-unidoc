import FNV1
import LexicalPaths

/// This codelink format is deprecated and should not be used in new documentation.
///
/// The type itself is not deprecated for backwards compatibility reasons.
@frozen public
struct CodelinkV3:Equatable, Hashable, Sendable
{
    public
    let filter:Filter?
    public
    let scope:Scope?
    public
    let path:Path
    public
    let hash:FNV24?

    @inlinable public
    init(filter:Filter? = nil, scope:Scope? = nil, path:Path, hash:FNV24? = nil)
    {
        self.filter = filter
        self.scope = scope
        self.path = path
        self.hash = hash
    }
}
extension CodelinkV3:CustomStringConvertible
{
    public
    var description:String
    {
        var words:[String] = []

        switch self.filter?.keywords
        {
        case nil:
            break

        case (let first, nil)?:
            words = [first.rawValue]

        case (let first, let second?)?:
            words = [first.rawValue, second.rawValue]
        }

        if  let scope:Scope = self.scope
        {
            words.append("\(scope)")
        }

        words.append("\(self.path)")

        if let hash:FNV24 = self.hash
        {
            words.append("[\(hash)]")
        }

        return words.joined(separator: " ")
    }
}
extension CodelinkV3:LosslessStringConvertible
{
    public
    init?(_ string:String)
    {
        var string:Substring = string[...]

        var format:Path.Format = .unidoc
        var suffix:Suffix? = .hash(trimming: &string)

        var words:ArraySlice<Substring> = string.split(separator: " ")[...]

        guard
        let path:Substring = words.popLast(),
        let path:Path = .init(path, format: &format, suffix: &suffix)
        else
        {
            return nil
        }

        switch format
        {
        case .unidoc:
            if  case .filter? = suffix
            {
                //  Replacing the suffix value should have also set the format to `legacy`.
                fatalError("unreachable")
            }

            //  Need to parse swift keywords first, since unencased identifiers
            //  like 'static' are still parsable as path components.
            var keywords:(first:Keyword, second:Keyword?)? = nil

            while let word:Substring = words.popFirst()
            {
                switch (keywords, word)
                {
                case ((let first, nil)?, "func"):
                    keywords = (first, .func)
                    continue
                case ((let first, nil)?, "var"):
                    keywords = (first, .var)
                    continue

                case (nil, let first):
                    guard
                    let first:Keyword = .init(first)
                    else
                    {
                        fallthrough
                    }

                    keywords = (first, nil)
                    continue

                case _:
                    guard words.isEmpty,
                    let scope:Scope = .init(word)
                    else
                    {
                        return nil
                    }

                    self.init(keywords: keywords, scope: scope, path: path, suffix: suffix)
                    return
                }
            }

            self.init(keywords: keywords, scope: nil, path: path, suffix: suffix)

        case .legacy:
            //  legacy DocC links cannot use unidoc features
            guard words.isEmpty
            else
            {
                return nil
            }

            self.init(legacy: path, suffix: suffix)
        }
    }
}
extension CodelinkV3
{
    private
    init?(legacy path:consuming Path, suffix:Suffix?)
    {
        let prefix:[String] = path.components.prefix ; path.components.prefix = []
        let scope:Scope? = prefix.isEmpty ? nil : .init(prefix)

        switch suffix
        {
        case nil:
            self.init(filter: nil, scope: scope, path: path, hash: nil)

        case .hash(let hash)?:
            self.init(filter: nil, scope: scope, path: path, hash: hash)

        case .filter(let filter)?:
            self.init(filter: filter, scope: scope, path: path, hash: nil)
        }
    }

    private
    init?(keywords:(first:Keyword, second:Keyword?)?,
        scope:Scope?,
        path:Path,
        suffix:Suffix?)
    {
        let filter:Filter?

        switch (keywords, path.components.last)
        {
        case ((.actor, nil)?,           .nominal(_, nil)):  filter = .actor
        case ((.associatedtype, nil)?,  .nominal(_, nil)):  filter = .associatedtype
        case ((.case, nil)?,            .nominal):          filter = .case
        case ((.class, nil)?,           .nominal(_, nil)):  filter = .class
        case ((.class, nil)?,           .subscript):        filter = .subscript(.class)
        case ((.class, .func)?,         .nominal):          filter = .func(.class)
        case ((.class, .var)?,          .nominal(_, nil)):  filter = .var(.class)
        case ((.enum, nil)?,            .nominal(_, nil)):  filter = .enum
        case ((.func, nil)?,            .nominal):          filter = .func(.default)
        case ((.import, nil)?,          .nominal(_, nil)):  filter = .module
        case ((.macro, nil)?,           .nominal(_, nil)):  filter = .macro
        case ((.protocol, nil)?,        .nominal(_, nil)):  filter = .protocol
        case ((.static, nil)?,          .subscript):        filter = .subscript(.static)
        case ((.static, .func)?,        .nominal):          filter = .func(.static)
        case ((.static, .var)?,         .nominal(_, nil)):  filter = .var(.static)
        case ((.struct, nil)?,          .nominal(_, nil)):  filter = .struct
        case ((.typealias, nil)?,       .nominal(_, nil)):  filter = .typealias
        case ((.var, nil)?,             .nominal(_, nil)):  filter = .var(.default)

        case ((_, _)?, _):
            return nil

        case (nil, .subscript):
            filter = .subscript(.instance)

        case (nil, _):
            filter = nil
        }

        self.init(filter: filter, scope: scope, path: path, hash: suffix?.hash)
    }
}
