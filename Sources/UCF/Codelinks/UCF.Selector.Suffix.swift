import FNV1
import Grammar

extension UCF.Selector
{
    @frozen public
    enum Suffix:Equatable, Hashable, Sendable
    {
        case unidoc(UCF.Disambiguator)
        case legacy(UCF.LegacyFilter, FNV24?)
        case hash(FNV24)
    }
}
extension UCF.Selector.Suffix
{
    /// The `string` must start with a space (` `)!
    static func parse(unidoc string:Substring) -> Self?
    {
        let (signature, clauses):(UCF.SignaturePattern?, [(String, String?)])
        do
        {
            (signature, clauses) = try UCF.DisambiguatorRule.parse(string.unicodeScalars)
        }
        catch
        {
            //  TODO: Diagnose the error.
            return nil
        }

        if  let disambiguator:UCF.Disambiguator = .init(
                signature: signature,
                clauses: clauses,
                source: string)
        {
            return .unidoc(disambiguator)
        }
        else if
            case nil = signature,
            case (let hash, nil)? = clauses.first, clauses.count == 1,
            let hash:FNV24 = .init(hash)
        {
            return .hash(hash)
        }
        else
        {
            return nil
        }
    }

    /// The `string` must start with a hyphen (`-`)!
    static func parse(legacy string:Substring) -> Self?
    {
        let (signature, clauses):(UCF.SignaturePattern?, [(String, String?)])
        do
        {
            (signature, clauses) = try UCF.DisambiguationSuffixRule.parse(string.unicodeScalars)

            if  let disambiguator:UCF.Disambiguator = .init(
                    signature: signature,
                    clauses: clauses,
                    source: string)
            {
                return .unidoc(disambiguator)
            }
        }
        catch
        {
        }

        assert(string.startIndex < string.endIndex)

        /// Skip the leading hyphen.
        var i:String.Index = string.index(after: string.startIndex)

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
                let keywords:UCF.ConditionFilter.Keywords = .init(legacy: filter)
            {
                return .unidoc(.init(
                    conditions: [.init(keywords: keywords, expected: true)],
                    signature: nil))
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
