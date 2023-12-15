import BSON
import LexicalPaths
import Symbols
import UnidocAPI

extension Unidoc.Stem
{
    @inlinable internal
    init(_ namespace:Symbol.Module)
    {
        self.init(rawValue: "\(namespace)")
    }
    @inlinable public
    init(_ namespace:Symbol.Module, _ name:Substring)
    {
        self.init(rawValue: "\(namespace) \(name)")
    }
    public
    init(
        _ namespace:borrowing Symbol.Module,
        _ path:borrowing UnqualifiedPath,
        orientation:Phylum.Decl.Orientation)
    {
        self.init(rawValue: "\(namespace)")
        for component:String in path.prefix
        {
            self.append(straight: component)
        }
        switch orientation
        {
        case .straight: self.append(straight: path.last)
        case .gay:      self.append(gay: path.last)
        }
    }
}
extension Unidoc.Stem:BSONDecodable, BSONEncodable
{
}
