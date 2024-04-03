import SourceDiagnostics

extension SSGC.StdlibBuild
{
    @frozen public
    struct Logs
    {
        @inlinable public
        init()
        {
        }
    }
}
extension SSGC.StdlibBuild.Logs:SSGC.DocumentationLogger
{
    public
    func attach(extractorLog:[UInt8])
    {
    }

    public
    func attach(messages:consuming DiagnosticMessages)
    {
        messages.emit(colors: .enabled)
    }
}
