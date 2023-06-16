@frozen public
struct SourceText<File>
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
extension SourceText
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
extension SourceText:Equatable where File:Equatable
{
}
extension SourceText:Hashable where File:Hashable
{
}
extension SourceText:Sendable where File:Sendable
{
}
extension SourceText
{
    @inlinable public
    func map<T>(_ transform:(File) throws -> T) rethrows -> SourceText<T>
    {
        .init(range: self.range, file: try transform(file))
    }
}
