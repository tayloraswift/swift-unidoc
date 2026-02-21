@frozen public enum DiagnosticLine: Equatable, Sendable {
    case annotation(ClosedRange<Int>)
    case source(String)
}
extension DiagnosticLine {
    func write(to text: inout some TextOutputStream, colors: TerminalColors) {
        switch self {
        case .annotation(let underline):
            text.write(
                colors.bold(
                    """
                    \(String.init(repeating: " ", count: underline.lowerBound))\
                    \(String.init(repeating: "~", count: underline.count - 1))^
                    """,
                    .rgb(255, 70, 110)
                )
            )

        case .source(let line):
            text.write(line)
        }
    }
}
