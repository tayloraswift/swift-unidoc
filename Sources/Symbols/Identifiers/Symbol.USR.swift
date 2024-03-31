extension Symbol
{
    /// A unified symbol resolution (USR).
    ///
    /// Yes, the full name of the type contains the word “Symbol” twice. As *USR* is a term
    /// of art in the Swift and Clang compilers, it was judged to be the least confusing name
    /// among the possible alternatives.
    @frozen public
    enum USR:Hashable, Equatable, Sendable
    {
        /// A declaration vector. The Swift compiler calls these **synthesized
        /// value-declarations**.
        case vector(Decl.Vector)

        /// A declaration scalar. The Swift compiler calls these **value-declarations**.
        case scalar(Decl)

        /// An extension block. The payload is everything after the
        /// `s:e:` prefix, including any colons and special characters.
        /// The compiler calls these **extension-declarations**.
        case block(Block)
    }
}
extension Symbol.USR:CustomStringConvertible
{
    /// Dispatches to the enum payloads; see the documentation for each payload type.
    @inlinable public
    var description:String
    {
        switch self
        {
        case .vector(let vector):   "\(vector)"
        case .scalar(let scalar):   "\(scalar)"
        case .block(let block):     "\(block)"
        }
    }
}
extension Symbol.USR:LosslessStringConvertible
{
    /// Parses a USR from a string.
    public
    init?(_ string:String)
    {
        guard
        let l:String.Index = string.indices.first
        else
        {
            return nil
        }

        let colon:String.Index = string.index(after: l)

        guard colon < string.endIndex,
        case ":" = string[colon],
        let language:Unicode.Scalar = .init(string[l ..< colon]),
        let language:Symbol.Decl.Language = .init(language)
        else
        {
            return nil
        }

        let start:String.Index = string.index(after: colon)

        guard start < string.endIndex
        else
        {
            return nil
        }

        special:
        if  case .s = language,
            let i:String.Index = string[start...].firstIndex(of: ":")
        {
            let j:String.Index = string.index(after: i)

            if  case "e" = string[start ..< i]
            {
                self = .block(.init(name: String.init(string[j...])))
                return
            }

            //  Swift symbols should never contain interior colons
            if  let k:String.Index = string[j...].lastIndex(of: ":"),
                case "::SYNTHESIZED::s" = string[i ..< k],
                let feature:Symbol.Decl = .init(language, string[start ..< i]),
                let heir:Symbol.Decl = .init(.s, string[string.index(after: k)...])
            {
                self = .vector(.init(feature, self: heir))
                return
            }
            else
            {
                //  We know this symbol contains extra colons, but we don’t know what they mean
                //  so we must fail.
                return nil
            }
        }

        if  let symbol:Symbol.Decl = .init(language, string[start...])
        {
            self = .scalar(symbol)
        }
        else
        {
            return nil
        }
    }
}
