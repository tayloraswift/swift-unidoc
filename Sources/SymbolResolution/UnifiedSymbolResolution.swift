import JSONDecoding
import JSONEncoding
import Symbols

@frozen public
enum UnifiedSymbolResolution:Hashable, Equatable, Sendable
{
    /// A declaration compound. The compiler calls these synthesized
    /// value-declarations.
    case compound(UnifiedScalarResolution, self:UnifiedScalarResolution)
    /// A declaration scalar. The compiler calls these value-declarations.
    case scalar(UnifiedScalarResolution)
    /// An arbitrary code block. The payload is everything after the
    /// `s:e:` prefix, including any colons and special characters.
    /// The compiler calls these extension-declarations.
    case block(String)
}
extension UnifiedSymbolResolution:RawRepresentable
{
    @inlinable public
    init?(rawValue:String)
    {
        if  let index:String.Index = rawValue.index(rawValue.startIndex,
                offsetBy: 4,
                limitedBy: rawValue.endIndex),
            rawValue.prefix(upTo: index) == "s:e:"
        {
            self = .block(.init(rawValue.suffix(from: index)))
            return
        }

        let fragments:[Substring] = rawValue.split(separator: ":",
            omittingEmptySubsequences: true)
        
        switch fragments.count
        {
        case 2:
            if  let language:Unicode.Scalar = .init(fragments[0]),
                let symbol:SymbolIdentifier = .init(language, fragments[1])
            {
                self = .scalar(.init(symbol))
            }
            else
            {
                return nil
            }
        
        case 5:
            if  let language:Unicode.Scalar = .init(fragments[0]),
                let symbol:SymbolIdentifier = .init(language, fragments[1]),
                "SYNTHESIZED" == fragments[2],
                let language:Unicode.Scalar = .init(fragments[3]),
                let type:SymbolIdentifier = .init(language, fragments[4])
            {
                self = .compound(.init(symbol), self: .init(type))
            }
            else
            {
                return nil
            }
        
        case _:
            return nil
        }
    }
    @inlinable public
    var rawValue:String
    {
        switch self
        {
        case .compound(let base, self: let type):
            return base.rawValue + "::SYNTHESIZED::" + type.rawValue
        
        case .scalar(let base):
            return base.rawValue
        
        case .block(let name):
            return "s:e:" + name
        }
    }
}
extension UnifiedSymbolResolution:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension UnifiedSymbolResolution:JSONDecodable, JSONEncodable
{
}
