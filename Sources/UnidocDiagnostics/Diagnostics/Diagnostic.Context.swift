import Sources

extension Diagnostic
{
    @frozen public
    struct Context<File>
    {
        public
        let location:SourceLocation<File>?
        public
        var lines:[Line]

        @inlinable public
        init(location:SourceLocation<File>? = nil, lines:[Line] = [])
        {
            self.location = location
            self.lines = lines
        }
    }
}
extension Diagnostic.Context:Equatable where File:Equatable
{
}
extension Diagnostic.Context:Sendable where File:Sendable
{
}
extension Diagnostic.Context
{
    @inlinable public
    func symbolicated(with symbolicator:some Symbolicator<File>) -> Diagnostic.Context<String>
    {
        .init(
            location: self.location.map
            {
                (location:SourceLocation<File>) in symbolicator.path(of: location.file).map
                {
                    .init(position: location.position, file: $0)
                }
            } ?? nil,
            lines: self.lines)
    }
}
