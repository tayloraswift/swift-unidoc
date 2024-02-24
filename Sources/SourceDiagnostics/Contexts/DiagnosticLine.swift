@frozen public
enum DiagnosticLine:Equatable, Sendable
{
    case annotation(ClosedRange<Int>)
    case source(String)
}
extension DiagnosticLine
{
    func description(colors:TerminalColors) -> String
    {
        switch self
        {
        case .annotation(let underline):
            colors.bold("""
                \(String.init(repeating: " ", count: underline.lowerBound))\
                \(String.init(repeating: "~", count: underline.count - 1))^
                """,
                .rgb(255, 70, 110))

        case .source(let line):
            line
        }
    }
}
