import LexicalPaths
import ModuleGraphs

@frozen @usableFromInline internal
struct CodelinkResolutionPath:Equatable, Hashable, Sendable
{
    @usableFromInline internal
    let string:String

    @inlinable internal
    init(string:String)
    {
        self.string = string
    }
}
extension CodelinkResolutionPath
{
    @inlinable internal static
    func join(_ namespace:ModuleIdentifier, _ path:UnqualifiedPath, _ last:String) -> Self
    {
        .init(string: "\(namespace).\(path.joined(separator: ".")).\(last)")
    }
    @inlinable internal static
    func join(_ namespace:ModuleIdentifier, _ path:UnqualifiedPath) -> Self
    {
        .init(string: "\(namespace).\(path.joined(separator: "."))")
    }
    @inlinable internal static
    func join(_ components:[String]) -> Self
    {
        .init(string: components.joined(separator: "."))
    }
}
