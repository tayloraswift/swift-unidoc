import ModuleGraphs
import LexicalPaths
import Symbols
import Unidoc
import URI

enum StaticRoute:Equatable, Hashable, Sendable
{
    case main(String)
    case tutorial(String)
}
extension StaticRoute
{
    static
    func decl(_ namespace:ModuleIdentifier,
        _ path:UnqualifiedPath,
        _ phylum:Unidoc.Decl) -> Self
    {
        var stem:URI.Path = [.push("\(namespace)")]
        if  case .gay = phylum.orientation,
            let penultimate:Int = path.prefix.indices.last
        {
            stem += path.prefix[..<penultimate].lazy.map(URI.Path.Component.push(_:))
            stem.append("\(path.prefix[penultimate]).\(path.last)")
        }
        else
        {
            stem += path.lazy.map(URI.Path.Component.push(_:))
        }

        return .main("\(stem)".lowercased())
    }
    static
    func article(_ namespace:ModuleIdentifier, _ name:String) -> Self
    {
        .main("/\(namespace)/\(name)".lowercased())
    }
}
