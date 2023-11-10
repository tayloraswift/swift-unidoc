import Sources

extension DiagnosticContext
{
    @frozen @usableFromInline
    enum Group
    {
        case contextual(any Diagnostic<Symbolicator>,
            location:SourceLocation<Symbolicator.Address>?,
            context:SourceContext)

        case general(any Diagnostic<Symbolicator>)
    }
}
