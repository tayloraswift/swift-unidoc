import Sources

/// A `DiagnosticOutput` is just an opaque list of ``DiagnosticFragment``s glued to some
/// ``DiagnosticSymbolicator`` that individual ``Diagnostic``s can use to generate those
/// messages.
@frozen public
struct DiagnosticOutput<Symbolicator>:~Copyable where Symbolicator:DiagnosticSymbolicator
{
    public
    let symbolicator:Symbolicator

    @usableFromInline
    var fragments:[DiagnosticFragment]

    init(symbolicator:Symbolicator)
    {
        self.symbolicator = symbolicator
        self.fragments = []
    }
}
extension DiagnosticOutput
{
    @inlinable public
    subscript(type:DiagnosticPrefix) -> String
    {
        get
        {
            ""
        }
        set(value)
        {
            if !value.isEmpty
            {
                self.fragments.append(.message(type, value))
            }
        }
    }
}
extension DiagnosticOutput
{
    private mutating
    func wrap(with context:DiagnosticContext<Symbolicator.Address>?, _ yield:(inout Self) -> ())
    {
        guard
        let context:DiagnosticContext<Symbolicator.Address>
        else
        {
            yield(&self)
            return
        }

        if  let location:SourceLocation<Symbolicator.Address> = context.location,
            let path:String = self.symbolicator.path(of: location.file)
        {
            self.fragments.append(.heading(.init(position: location.position, file: path)))
        }
        else
        {
            self.fragments.append(.heading(nil))
        }

        yield(&self)

        if !context.lines.isEmpty
        {
            self.fragments.append(.context(context.lines))
        }
    }
}
extension DiagnosticOutput
{
    mutating
    func append(_ alert:DiagnosticAlert,
        with context:DiagnosticContext<Symbolicator.Address>?)
    {
        self.wrap(with: context)
        {
            $0.fragments.append(.message(alert.type, alert.text))
        }
    }
}
extension DiagnosticOutput
{
    /// Implicitly opened existentials don’t work with operators, so we need this hook.
    mutating
    func append<DiagnosticType>(_ diagnostic:DiagnosticType,
        with context:DiagnosticContext<Symbolicator.Address>?)
        where DiagnosticType:Diagnostic<Symbolicator>
    {
        self.wrap(with: context)
        {
            diagnostic.emit(summary: &$0)
        }

        diagnostic.emit(details: &self)
    }
}
