import Sources

@frozen @usableFromInline
enum DiagnosticFragment
{
    case heading(SourceLocation<String>?)
    case message(DiagnosticPrefix, String)
    case context([DiagnosticLine])
}
extension DiagnosticFragment:CustomStringConvertible
{
    @usableFromInline
    var description:String
    {
        self.description(colors: .disabled)
    }
}
extension DiagnosticFragment
{
    @usableFromInline
    func description(colors:TerminalColors) -> String
    {
        switch self
        {
        case .heading(let location?):
            return "\(location): "

        case .heading(nil):
            return "(unknown) "

        case .message(let prefix, let text):
            return "\(colors.bold("\(prefix):", prefix.color)) \(colors.bold(text))\n"

        case .context(let context):
            var lines:String = ""
            for line:DiagnosticLine in context
            {
                lines += line.description(colors: colors)
                lines.append("\n")
            }

            return lines
        }
    }
}
