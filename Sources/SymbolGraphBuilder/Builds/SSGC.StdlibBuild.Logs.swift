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
    func log(messages:consuming DiagnosticMessages)
    {
        messages.emit(colors: .enabled)
    }
}
