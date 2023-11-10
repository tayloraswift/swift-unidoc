@frozen public
struct SourceContext
{
    public
    var lines:[Line]

    @inlinable public
    init(lines:[Line] = [])
    {
        self.lines = lines
    }
}
extension SourceContext:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Line...)
    {
        self.init(lines: arrayLiteral)
    }
}
extension SourceContext
{
    func description(colors:TerminalColors) -> String
    {
        self.lines.lazy.map { $0.description(colors: colors) }
            .joined(separator: "\n")
    }
}
