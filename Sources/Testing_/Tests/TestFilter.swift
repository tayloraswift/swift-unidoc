public
enum TestFilter
{
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    case regex(Any)
    #else
    case regex([Regex<Substring>])
    #endif

    case path([String])
}
extension TestFilter
{
    init(arguments:ArraySlice<String>) throws
    {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
        {
            let regex:[Regex<Substring>] = try arguments.map
            {
                try .init($0, as: Substring.self)
            }
            self = .regex(regex)
        }
        else
        {
            self = .path(.init(arguments))
        }
    }
}
extension TestFilter
{
    public static
    func ~= (self:Self, path:[String]) -> Bool
    {
        switch self
        {
        case .path(let filter):
            for (filter, component):(String, String) in zip(filter, path)
                where filter != component
            {
                return false
            }
        
        case .regex(let filter):
            if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
            {
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                let filter:[Regex<Substring>] = filter as! [Regex<Substring>]
                #endif
                for (filter, component):(Regex<Substring>, String) in zip(filter, path)
                {
                    if  case nil = try? filter.wholeMatch(in: component)
                    {
                        return false
                    }
                }
            }
        }
        return true
    }
}
