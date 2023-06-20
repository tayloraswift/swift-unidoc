import ModuleGraphs
import LexicalPaths
import Symbols
import URI

@frozen public
enum StaticPath:Equatable, Hashable, Sendable
{
    case declaration(String)
    case standalone(String)
    case tutorial(String)
}
extension StaticPath
{
    public static
    func declaration(_ namespace:ModuleIdentifier,
        _ path:UnqualifiedPath,
        _ phylum:ScalarPhylum) -> Self
    {
        var stem:URI.Path = [.push("\(namespace)")]
        switch phylum
        {
        case .case, .deinitializer, .func, .initializer, .operator, .subscript, .var:
            guard let penultimate:Int = path.prefix.indices.last
            else
            {
                fallthrough
            }
            stem += path.prefix[..<penultimate].lazy.map(URI.Path.Component.push(_:))
            stem.append("\(path.prefix[penultimate]).\(path.last)")

        case .actor, .associatedtype, .class, .enum, .protocol, .struct, .typealias:
            stem += path.lazy.map(URI.Path.Component.push(_:))
        }

        return .declaration("\(stem)".lowercased())
    }
    public static
    func standalone(_ namespace:ModuleIdentifier, _ name:String) -> Self
    {
        .standalone("/\(namespace)/\(name)".lowercased())
    }
}
