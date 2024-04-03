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
        var text:String = ""
        self.write(to: &text, colors: .disabled)
        return text
    }
}
extension DiagnosticFragment
{
    func write(to text:inout some TextOutputStream, colors:TerminalColors)
    {
        switch self
        {
        case .heading(let location?):
            text.write("\(location): ")

        case .heading(nil):
            text.write("(unknown) ")

        case .message(let prefix, let message):
            text.write("\(colors.bold("\(prefix):", prefix.color)) \(colors.bold(message))\n")

        case .context(let context):
            for line:DiagnosticLine in context
            {
                line.write(to: &text, colors: colors)
                text.write("\n")
            }
        }
    }
}
