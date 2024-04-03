import SourceDiagnostics

extension SSGC
{
    protocol DocumentationLogger
    {
        mutating
        func attach(extractorLog:[UInt8])

        mutating
        func attach(messages:consuming DiagnosticMessages)
    }
}
