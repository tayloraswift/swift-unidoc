import SourceDiagnostics

extension SSGC.PackageBuild
{
    @frozen public
    struct Logs
    {
        public
        var swiftPackageResolve:[UInt8]?
        public
        var swiftPackageBuild:[UInt8]?
        public
        var ssgcDiagnostics:[UInt8]?

        @inlinable public
        init()
        {
            self.swiftPackageResolve = nil
            self.swiftPackageBuild = nil
            self.ssgcDiagnostics = nil
        }
    }
}
extension SSGC.PackageBuild.Logs:SSGC.DocumentationLogger
{
    public mutating
    func log(messages:consuming DiagnosticMessages)
    {
        {
            (buffer:inout [UInt8]?) in

            let text:String = "\(messages)"

            if  var utf8:[UInt8] = consume buffer
            {
                utf8 += text.utf8
                buffer = utf8
            }
            else
            {
                buffer = [UInt8].init(text.utf8)
            }

        } (&self.ssgcDiagnostics)
    }
}
