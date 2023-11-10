import Sources

@frozen public
enum DiagnosticMessage
{
    case diagnostic(Severity, String)
    case sourceContext(SourceContext)
    case sourceLocation(SourceLocation<String>?)
}
extension DiagnosticMessage:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.description(colors: .disabled)
    }
}
extension DiagnosticMessage
{
    public
    func description(colors:TerminalColors) -> String
    {
        switch self
        {
        case .diagnostic(let severity, let message):
             "\(colors.bold("\(severity):", severity.color)) \(message)\n"

        case .sourceContext(let context):
            "\(context.description(colors: colors))\n"

        case .sourceLocation(let location?):
            "\(location): "

        case .sourceLocation(nil):
            "(unknown) "
        }
    }
}
