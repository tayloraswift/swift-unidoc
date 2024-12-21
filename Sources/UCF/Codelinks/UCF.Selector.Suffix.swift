import FNV1

extension UCF.Selector
{
    @frozen public
    enum Suffix:Equatable, Hashable, Sendable
    {
        case filter(UCF.KeywordFilter)
        case legacy(UCF.LegacyFilter, FNV24?)
        case pattern(UCF.PatternFilter)
        case hash(FNV24)
    }
}
extension UCF.Selector.Suffix
{
    static func parse(legacy string:Substring) -> Self?
    {
        if  let pattern:UCF.PatternFilter = .parse(string)
        {
            return .pattern(pattern)
        }

        var i:String.Index = string.startIndex

        var filter:UCF.LegacyFilter? = nil
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

        if  let filter:UCF.LegacyFilter
        {
            if  case nil = hash,
                let filter:UCF.KeywordFilter = .init(legacy: filter)
            {
                return .filter(filter)
            }
            else
            {
                return .legacy(filter, hash)
            }
        }
        else
        {
            if  let hash:FNV24
            {
                return .hash(hash)
            }
            else
            {
                return nil
            }
        }
    }
}
