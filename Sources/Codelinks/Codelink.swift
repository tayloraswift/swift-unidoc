import Symbols

@frozen public
struct Codelink:Equatable, Hashable, Sendable
{
    public
    let filter:SymbolPhylum.Filter?
    public
    let scope:Scope?
    public
    let path:Path
    public
    let hash:Hash?

    @inlinable public
    init(filter:SymbolPhylum.Filter? = nil, scope:Scope? = nil, path:Path, hash:Hash? = nil)
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

        outer:
        while let word:Substring = words.popFirst()
        {
            switch (keywords, word)
            {
            case (nil, "actor"):                keywords = (.actor, nil)
            case (nil, "associatedtype"):       keywords = (.associatedtype, nil)
            case (nil, "case"):                 keywords = (.case, nil)
            case (nil, "class"):                keywords = (.class, nil)
            case (nil, "enum"):                 keywords = (.enum, nil)
            case (nil, "func"):                 keywords = (.func, nil)
            case (nil, "macro"):                keywords = (.macro, nil)
            case (nil, "protocol"):             keywords = (.protocol, nil)
            case (nil, "static"):               keywords = (.static, nil)
            case (nil, "struct"):               keywords = (.struct, nil)
            case (nil, "typealias"):            keywords = (.typealias, nil)
            case (nil, "var"):                  keywords = (.var, nil)

            case ((let first, nil)?, "func"):   keywords = (first, .func)
            case ((let first, nil)?, "var"):    keywords = (first, .var)

            case (_, let word):
                if  words.isEmpty
                {
                    scope = .init(word)
                    break outer
                }
                else
                {
                    return nil
                }
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
        let filter:SymbolPhylum.Filter?

        if  let keywords:(first:Keyword, second:Keyword?)
        {
            switch (keywords, path.components.last)
            {
            case ((.actor, nil),            .nominal(_, nil)):  filter = .actor
            case ((.associatedtype, nil),   .nominal(_, nil)):  filter = .associatedtype
            case ((.case, nil),             .nominal):          filter = .case
            case ((.class, nil),            .nominal(_, nil)):  filter = .class
            case ((.class, nil),            .subscript):        filter = .subscript(.class)
            case ((.class, .func),          .nominal):          filter = .func(.class)
            case ((.class, .var),           .nominal(_, nil)):  filter = .var(.class)
            case ((.enum, nil),             .nominal(_, nil)):  filter = .enum
            case ((.func, nil),             .nominal):          filter = .func(.default)
            case ((.macro, nil),            .nominal(_, nil)):  filter = .macro
            case ((.protocol, nil),         .nominal(_, nil)):  filter = .protocol
            case ((.static, nil),           .subscript):        filter = .subscript(.static)
            case ((.static, .func),         .nominal):          filter = .func(.static)
            case ((.static, .var),          .nominal(_, nil)):  filter = .var(.static)
            case ((.struct, nil),           .nominal(_, nil)):  filter = .struct
            case ((.typealias, nil),        .nominal(_, nil)):  filter = .typealias
            case ((.var, nil),              .nominal(_, nil)):  filter = .var(.default)
            default:                                            return nil
            }
        }
        else
        {
            switch (suffix, path.components.last)
            {
            ///  cannot use legacy DocC suffixes with anonymous symbols
            case    (.filter?,              .`init`),
                    (.filter?,              .deinit),
                    (.filter?,              .subscript):        return nil
            case    (.filter(let legacy)?,  .nominal):          filter = legacy

            case    (_,                     .`init`):           filter = .initializer
            case    (_,                     .deinit):           filter = .deinitializer
            case    (_,                     .subscript):        filter = .subscript(.instance)
            case    (_,                     .nominal):          filter = nil
            }
        }

        self.init(filter: filter, scope: scope, path: path, hash: suffix?.hash)
    }
}
