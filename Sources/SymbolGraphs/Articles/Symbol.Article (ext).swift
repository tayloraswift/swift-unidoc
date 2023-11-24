import BSONDecoding
import BSONEncoding
import Symbols

/// Uses the ``RawRepresentable`` conformance.
extension Symbol.Article:BSONDecodable, BSONEncodable
{
}
extension Symbol.Article
{
    @inlinable public
    init(_ bundle:borrowing Symbol.Module, _ name:borrowing String)
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
