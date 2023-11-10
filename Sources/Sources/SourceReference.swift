@frozen public
struct SourceReference<File>
{
    public
    let file:File
    public
    let range:Range<SourcePosition>?

    @inlinable public
    init(file:File, range:Range<SourcePosition>?)
    {
        self.file = file
        self.range = range
    }
}
extension SourceReference:Equatable where File:Equatable
{
}
extension SourceReference:Hashable where File:Hashable
{
}
extension SourceReference:Sendable where File:Sendable
{
}
extension SourceReference
{
    @inlinable public
    func map<T>(_ transform:(File) throws -> T) rethrows -> SourceReference<T>
    {
        .init(file: try transform(file), range: self.range)
    }
}
