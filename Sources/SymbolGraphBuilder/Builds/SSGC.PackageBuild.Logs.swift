import SourceDiagnostics

extension SSGC.PackageBuild
{
    @frozen public
    struct Logs
    {
        public
        var swiftPackageResolution:[UInt8]?
        public
        var swiftPackageBuild:[UInt8]?
        /// The concatenated `swift symbolgraph-extract` logs.
        ///
        /// Please note for some reason, whoever named the tool rendered the term *symbol graph*
        /// as a portmanteau, but the property renders it as two words for consistency with the
        /// rest of the project. When using camel case, the *G* in *Graph* **must** always be
        /// capitalized!
        public
        var swiftSymbolGraphExtract:[UInt8]?
        public
        var ssgcDocsBuild:[UInt8]?

        @inlinable public
        init()
        {
            self.swiftPackageResolution = nil
            self.swiftPackageBuild = nil
            self.swiftSymbolGraphExtract = nil
            self.ssgcDocsBuild = nil
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

        } (&self.ssgcDocsBuild)
    }
}
