import Sources
import Symbols

public
struct StaticDiagnostic
{
    /// The severity of the message.
    public
    let severity:Severity
    let context:Context<String>?
    /// The text of the message. This should *not* include trailing punctuation.
    public
    let message:String

    init(_ severity:Severity = .note, context:Context<String>? = nil, message:String)
    {
        self.severity = severity
        self.context = context
        self.message = message
    }
}
extension StaticDiagnostic:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.description(colors: .disabled)
    }
}
extension StaticDiagnostic
{
    public
    func description(colors:TerminalColors) -> String
    {
        var description:String = colors.bold("""
            \((self.context?.header).map { "\($0):" } ?? "(unknown)") \
            \(colors.color("\(self.severity):", self.severity.color)) \(self.message)
            """)
        if  let context:Context<String> = self.context
        {
            for line:Line in context.lines
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
        }
        return description
    }
}
