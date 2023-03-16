@frozen public
struct SourceLocation<File>
{
    public
    let file:File
    public
    let line:Int 
    public
    let column:Int

    @inlinable public
    init(file:File, _ line:Int = #line, _ column:Int = #column)
    {
        self.file = file
        self.line = line
        self.column = column
    }
}
extension SourceLocation:Sendable where File:Sendable
{
}
extension SourceLocation:Equatable where File:Equatable
{
}
extension SourceLocation:Hashable where File:Hashable
{
}
