import JSONDecoding
import JSONEncoding
import Symbols

@frozen public
enum UnifiedSymbolResolution:Hashable, Equatable, Sendable
{
    /// A declaration compound. The compiler calls these synthesized
    /// value-declarations.
    case compound(ScalarSymbolResolution, self:ScalarSymbolResolution)
    /// A declaration scalar. The compiler calls these value-declarations.
    case scalar(ScalarSymbolResolution)
    /// An arbitrary code block. The payload is everything after the
    /// `s:e:` prefix, including any colons and special characters.
    /// The compiler calls these extension-declarations.
    case block(BlockSymbolResolution)
}
extension UnifiedSymbolResolution:LosslessStringConvertible, CustomStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        if  let block:BlockSymbolResolution = .init(description)
        {
            self = .block(block)
            return
        }

        let fragments:[Substring] = description.split(separator: ":",
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
    var description:String
    {
        switch self
        {
        case .compound(let base, self: let type):
            return base.description + "::SYNTHESIZED::" + type.description
        
        case .scalar(let base):
            return base.description
        
        case .block(let block):
            return block.description
        }
    }
}
extension UnifiedSymbolResolution:JSONStringDecodable, JSONStringEncodable
{
}
