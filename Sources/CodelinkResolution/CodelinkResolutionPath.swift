import LexicalPaths
import Symbols

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
    @inlinable internal
    init(_ namespace:Symbol.Module)
    {
        self.init(string: "\(namespace)")
    }

    @inlinable internal static
    func join(_ namespace:Symbol.Module, _ path:UnqualifiedPath, _ last:String) -> Self
    {
        .init(string: "\(namespace).\(path.joined(separator: ".")).\(last)")
    }
    @inlinable internal static
    func join(_ namespace:Symbol.Module, _ path:UnqualifiedPath) -> Self
    {
        .init(string: "\(namespace).\(path.joined(separator: "."))")
    }
    @inlinable internal static
    func join(_ components:[String]) -> Self
    {
        .init(string: components.joined(separator: "."))
    }
}
