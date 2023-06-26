@frozen public
struct Diagnostic
{
    /// The severity of the message.
    public
    let severity:Severity
    public
    let context:Context<String>
    /// The text of the message. This should *not* include trailing punctuation.
    public
    let message:String

    @inlinable public
    init(_ severity:Severity = .note, context:Context<String> = .init(), message:String)
    {
        self.severity = severity
        self.context = context
        self.message = message
    }
}
extension Diagnostic:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.description(colors: .disabled)
    }
}
extension Diagnostic
{
    public
    func description(colors:TerminalColors) -> String
    {
        var description:String = colors.bold("""
            \(self.context.location.map { "\($0):" } ?? "(unknown)") \
            \(colors.color("\(self.severity):", self.severity.color)) \(self.message)
            """)
        for line:Line in self.context.lines
        {
            switch line
            {
            case .source(let line):
                description += "\n\(line)"

            case .annotation(let underline):
                description += colors.bold("""

                    \(String.init(repeating: " ", count: underline.lowerBound))\
                    \(String.init(repeating: "~", count: underline.count - 1))^
                    """,
                    .rgb(255, 70, 110))
            }
        }
        return description
    }
}
