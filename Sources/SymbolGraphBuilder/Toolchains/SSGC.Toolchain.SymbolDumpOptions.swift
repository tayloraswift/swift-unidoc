import Symbols

extension SSGC.Toolchain
{
    struct SymbolDumpOptions
    {
        var minimumACL:Symbol.ACL
        var emitExtensionBlockSymbols:Bool
        var includeInterfaceSymbols:Bool
        var skipInheritedDocs:Bool

        init(minimumACL:Symbol.ACL,
            emitExtensionBlockSymbols:Bool,
            includeInterfaceSymbols:Bool,
            skipInheritedDocs:Bool)
        {
            self.minimumACL = minimumACL
            self.emitExtensionBlockSymbols = emitExtensionBlockSymbols
            self.includeInterfaceSymbols = includeInterfaceSymbols
            self.skipInheritedDocs = skipInheritedDocs
        }
    }
}
extension SSGC.Toolchain.SymbolDumpOptions
{
    static
    var `default`:Self
    {
        .init(minimumACL: .internal,
            emitExtensionBlockSymbols: true,
            includeInterfaceSymbols: true,
            skipInheritedDocs: true)
    }
}
