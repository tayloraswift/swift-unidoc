extension DiagnosticContext
{
    struct Symbolicated
    {
        let symbolicator:Symbolicator
        let diagnostics:DiagnosticContext<Symbolicator>

        init(symbolicator:Symbolicator, diagnostics:DiagnosticContext<Symbolicator>)
        {
            self.symbolicator = symbolicator
            self.diagnostics = diagnostics
        }
    }
}
extension DiagnosticContext.Symbolicated:Diagnostics
{
    func emit(colors:TerminalColors)
    {
        var first:Bool = true
        for message:DiagnosticMessage in self.symbolicator.symbolicate(self.diagnostics)
        {
            if  first
            {
                first = false
            }
            else if case .sourceLocation = message
            {
                Swift.print()
            }

            Swift.print(message.description(colors: colors))
        }
    }
}
