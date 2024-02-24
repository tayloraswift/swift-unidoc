import Sources

@frozen @usableFromInline
struct DiagnosticContext<File>
{
    @usableFromInline
    let location:SourceLocation<File>?
    @usableFromInline
    let lines:[DiagnosticLine]

    @inlinable
    init(location:SourceLocation<File>?, lines:[DiagnosticLine] = [])
    {
        self.location = location
        self.lines = lines
    }
}
extension DiagnosticContext
{
    @usableFromInline static
    func around(_ subject:SourceReference<some DiagnosticFrame<File>>) -> Self
    {
        .init(location: subject.start, lines: subject.range.map { subject.frame[$0] } ?? [])
    }
}
