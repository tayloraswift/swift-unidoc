@frozen @usableFromInline internal
struct DoclinkResolutionPath:Equatable, Hashable, Sendable
{
    @usableFromInline internal
    let string:String

    @inlinable internal
    init(string:String)
    {
        self.string = string
    }
}
extension DoclinkResolutionPath
{
    @inlinable internal static
    func join(_ components:[String]) -> Self
    {
        .init(string: components.joined(separator: "/"))
    }
}
