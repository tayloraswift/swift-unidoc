@available(*, deprecated, renamed: "SourceReference")
public
typealias SourceText = SourceReference

@frozen public
struct SourceReference<File>
{
    public
    let range:Range<SourcePosition>
    public
    let file:File

    @inlinable public
    init(range:Range<SourcePosition>, file:File)
    {
        self.range = range
        self.file = file
    }
}
extension SourceReference
{
    @inlinable public
    var start:SourceLocation<File>
    {
        .init(position: self.range.lowerBound, file: self.file)
    }
    @inlinable public
    var end:SourceLocation<File>
    {
        .init(position: self.range.upperBound, file: self.file)
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
        .init(range: self.range, file: try transform(file))
    }
}
