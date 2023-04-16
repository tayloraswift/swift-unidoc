import JSONDecoding
import JSONEncoding
import Symbols

/// A symbol resolution. The only difference between a symbol resolution
/// and a symbol identifier is a symbol resolution contains a colon after
/// its language prefix, like `s:s17FloatingPointSignO`.
@frozen public
struct ScalarSymbolResolution:Equatable, Hashable
{
    public
    let id:SymbolIdentifier

    @inlinable public
    init(_ id:SymbolIdentifier)
    {
        self.id = id
    }
}
extension ScalarSymbolResolution:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool 
    {
        lhs.id < rhs.id
    }
}
extension ScalarSymbolResolution:LosslessStringConvertible, CustomStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        let fragments:[Substring] = description.split(separator: ":",
            omittingEmptySubsequences: true)
        
        if  fragments.count == 2,
            let language:Unicode.Scalar = .init(fragments[0]),
            let symbol:SymbolIdentifier = .init(language, fragments[1])
        {
            self.init(symbol)
        }
        else
        {
            return nil
        }
    }
    @inlinable public
    var description:String
    {
        "\(self.id.language):\(self.id.suffix)"
    }
}
extension ScalarSymbolResolution:JSONStringDecodable, JSONStringEncodable
{
}
