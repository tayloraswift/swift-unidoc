import SourceDiagnostics

extension SSGC
{
    protocol DocumentationLogger
    {
        mutating
        func log(messages:consuming DiagnosticMessages)
    }
}
