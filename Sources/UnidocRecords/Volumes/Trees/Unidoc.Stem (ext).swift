import BSON
import LexicalPaths
import Symbols
import UnidocAPI

extension Unidoc.Stem
{
    @inlinable internal static
    func product(_ name:Symbol.Module) -> Self
    {
        "\(name)-product"
    }

    @inlinable internal static
    func module(_ namespace:Symbol.Module) -> Self
    {
        "\(namespace)"
    }

    @inlinable public static
    func article(_ namespace:Symbol.Module, path:Substring) -> Self
    {
        "\(namespace) \(path)"
    }

    public static
    func decl(
        _ namespace:Symbol.Module,
        _ path:UnqualifiedPath,
        orientation:Phylum.Decl.Orientation) -> Self
    {
        var stem:Self = "\(namespace)"
        for component:String in path.prefix
        {
            stem.append(straight: component)
        }
        switch orientation
        {
        case .straight: stem.append(straight: path.last)
        case .gay:      stem.append(gay: path.last)
        }

        return stem
    }
}
extension Unidoc.Stem:BSONDecodable, BSONEncodable
{
}
