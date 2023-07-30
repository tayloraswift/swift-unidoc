import BSONDecoding
import BSONEncoding
import ModuleGraphs
import Symbols

/// Uses the ``RawRepresentable`` conformance.
extension Symbol.Article:BSONDecodable, BSONEncodable
{
}
extension Symbol.Article
{
    @inlinable public
    init(_ bundle:ModuleIdentifier, _ name:String)
    {
        self.init(rawValue: "\(bundle) \(name)")
    }

    @inlinable public
    var name:Substring
    {
        self.rawValue.firstIndex(of: " ").map
        {
            self.rawValue[self.rawValue.index(after: $0)...]
        } ?? self.rawValue[...]
    }
}
