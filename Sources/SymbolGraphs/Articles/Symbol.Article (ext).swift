import BSON
import Symbols

/// Uses the ``RawRepresentable`` conformance.
extension Symbol.Article:BSONDecodable, BSONEncodable
{
}
extension Symbol.Article
{
    /// Creates an article symbol.
    @inlinable public static
    func article(_ namespace:borrowing Symbol.Module, _ name:borrowing String) -> Self
    {
        .init(rawValue: "\(namespace) \(name)")
    }

    // Creates an article symbol appropriate for a tutorial.
    @inlinable public static
    func tutorial(_ namespace:borrowing Symbol.Module, _ name:borrowing String) -> Self
    {
        .init(rawValue: "\(namespace) \(name)\ttutorial")
    }

    /// Returns the space-separated article path without the module qualifier.
    @inlinable public
    var path:Substring
    {
        if  let i:String.Index = self.rawValue.firstIndex(of: " ")
        {
            self.rawValue[self.rawValue.index(after: i)...]
        }
        else
        {
            self.rawValue[...]
        }
    }
}
