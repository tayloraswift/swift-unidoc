import Symbols

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
    let hash:Hash?

    @inlinable public
    init(filter:Filter? = nil, scope:Scope? = nil, path:Path, hash:Hash? = nil)
    {
        self.filter = filter
        self.scope = scope
        self.path = path
        self.hash = hash
    }
}
extension Codelink
{
    public
    init?(parsing string:String)
    {
        var string:Substring = string[...]

        var suffix:Path.Suffix? = nil
        if  let hash:Hash = .init(parsing: &string)
        {
            suffix = .hash(hash)
        }

        var words:ArraySlice<Substring> = string.split(separator: " ")[...]

        guard   let path:Substring = words.popLast(),
                let path:Path = .init(path, suffix: &suffix)
        else
        {
            return nil
        }

        //  legacy DocC links cannot use unidoc features
        if !words.isEmpty
        {
            if case .legacy? = path.collation
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

        self.init(keywords: keywords, scope: scope, path: path, suffix: suffix)
    }

    private
    init?(keywords:(first:Keyword, second:Keyword?)?,
        scope:Scope?,
        path:Path,
        suffix:Path.Suffix?)
    {
        let filter:Filter?

        switch path.collation
        {
        case nil:
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
        
        case .legacy?:
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
extension Codelink:CustomStringConvertible
{
    public
    var description:String
    {
        switch self.path.collation
        {
        case nil:
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

            if let scope:Scope = self.scope
            {
                words.append(scope.description)
            }

            words.append(self.path.components.joined(separator: "."))

            if let hash:Hash = self.hash
            {
                words.append("[\(hash.description)]")
            }

            return words.joined(separator: " ")

        case .legacy?:
            return """
            \(self.path.components.joined(separator: "/"))-\
            \(self.hash?.description ?? self.filter?.suffix ?? "")
            """
        }
    }
}
