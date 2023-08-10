import FNV1
import LexicalPaths

@frozen public
struct Codelink:Equatable, Hashable, Sendable
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
extension Codelink:CustomStringConvertible
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
extension Codelink:LosslessStringConvertible
{
    public
    init?(_ string:String)
    {
        var string:Substring = string[...]

        var format:Path.Format = .unidoc
        var suffix:Suffix? = .hash(trimming: &string)

        var words:ArraySlice<Substring> = string.split(separator: " ")[...]

        guard   let path:Substring = words.popLast(),
                let path:Path = .init(path, format: &format, suffix: &suffix)
        else
        {
            return nil
        }

        //  legacy DocC links cannot use unidoc features
        if !words.isEmpty
        {
            if case .legacy = format
            {
                return nil
            }
            if case .filter? = suffix
            {
                return nil
            }
        }

        //  Need to parse swift keywords first, since unencased identifiers
        //  like 'static' are still parsable as path components.
        var keywords:(first:Keyword, second:Keyword?)? = nil
        var scope:Scope? = nil

        while   let word:Substring = words.popFirst(),
                let word:Scope = .init(word)
        {
            switch (keywords, Keyword.init(word))
            {
            case (nil, let first?):
                keywords = (first, nil)
                continue

            case ((let first, nil)?, .func?):
                keywords = (first, .func)
                continue
            case ((let first, nil)?, .var?):
                keywords = (first, .var)
                continue

            case ((_, _)?, _?):
                return nil

            default:
                break
            }

            if  words.isEmpty
            {
                scope = word
                break
            }
            else
            {
                return nil
            }
        }

        self.init(keywords: keywords, scope: scope, path: path, format: format, suffix: suffix)
    }
}
extension Codelink
{
    private
    init?(keywords:(first:Keyword, second:Keyword?)?,
        scope:Scope?,
        path:Path,
        format:Path.Format,
        suffix:Suffix?)
    {
        let filter:Filter?

        switch format
        {
        case .unidoc:
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

        case .legacy:
            if case .filter(let legacy)? = suffix
            {
                filter = legacy
            }
            else
            {
                filter = nil
            }
        }

        self.init(filter: filter, scope: scope, path: path, hash: suffix?.hash)
    }
}
