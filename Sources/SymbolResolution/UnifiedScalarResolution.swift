import JSONDecoding
import JSONEncoding
import Symbols

/// A symbol resolution. The only difference between a symbol resolution
/// and a symbol identifier is a symbol resolution contains a colon after
/// its language prefix, like `s:s17FloatingPointSignO`.
@frozen public
struct UnifiedScalarResolution
{
    public
    let id:SymbolIdentifier

    @inlinable public
    init(_ id:SymbolIdentifier)
    {
        self.id = id
    }
}
extension UnifiedScalarResolution:Hashable, Equatable
{
}
extension UnifiedScalarResolution:RawRepresentable
{
    @inlinable public
    init?(rawValue:String)
    {
        let fragments:[Substring] = rawValue.split(separator: ":",
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
    var rawValue:String
    {
        self.id.rawValue.unicodeScalars.first.map
        {
            "\($0):\(self.id.rawValue.unicodeScalars.dropFirst())"
        } ?? ""
    }
}
extension UnifiedScalarResolution:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension UnifiedScalarResolution:JSONDecodable, JSONEncodable
{
}
