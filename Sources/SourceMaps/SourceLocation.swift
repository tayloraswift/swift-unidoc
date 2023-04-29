@frozen public
struct SourceLocation<File>
{
    public
    let position:SourcePosition
    public
    let file:File

    @inlinable public
    init(position:SourcePosition, file:File)
    {
        self.position = position
        self.file = file
    }
}
extension SourceLocation:Equatable where File:Equatable
{
}
extension SourceLocation:Hashable where File:Hashable
{
}
extension SourceLocation:Sendable where File:Sendable
{
}
// extension SourceLocation:Comparable where File:Comparable
// {
//     @inlinable public static
//     func < (lhs:Self, rhs:Self) -> Bool
//     {
//         (lhs.file, lhs.position) < (rhs.file, rhs.position)
//     }
// }
extension SourceLocation
{
    @inlinable public
    func map<T>(_ transform:(File) throws -> T) rethrows -> SourceLocation<T>
    {
        .init(position: self.position, file: try transform(file))
    }
}
extension SourceLocation:CustomStringConvertible where File:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.file):\(self.position)"
    }
}
