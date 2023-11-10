@frozen public
struct DiagnosticOutput<Symbolicator>:~Copyable where Symbolicator:DiagnosticSymbolicator
{
    public
    let symbolicator:Symbolicator

    @usableFromInline internal
    var messages:[DiagnosticMessage]

    @inlinable internal
    init(symbolicator:Symbolicator)
    {
        self.symbolicator = symbolicator
        self.messages = []
    }
}
extension DiagnosticOutput
{
    @inlinable public
    subscript(severity:DiagnosticMessage.Severity) -> String
    {
        get
        {
            ""
        }
        set(value)
        {
            if !value.isEmpty
            {
                self.messages.append(.diagnostic(severity, value))
            }
        }
    }
}
extension DiagnosticOutput
{
    /// Implicitly opened existentials don’t work with operators, so we need this hook.
    mutating
    func append<DiagnosticType>(_ diagnostic:DiagnosticType, with context:SourceContext)
        where DiagnosticType:Diagnostic<Symbolicator>
    {
        self += diagnostic

        if !context.lines.isEmpty
        {
            self.messages.append(.sourceContext(context))
        }

        for note:DiagnosticType.Note in diagnostic.notes
        {
            self += note
        }
    }
}
