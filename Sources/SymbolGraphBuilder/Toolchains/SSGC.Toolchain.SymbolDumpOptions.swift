import Symbols

extension SSGC.Toolchain
{
    struct SymbolDumpOptions
    {
        var minimumACL:Symbol.ACL
        var emitExtensionBlockSymbols:Bool
        var includeInterfaceSymbols:Bool
        var skipInheritedDocs:Bool

        init(minimumACL:Symbol.ACL = .internal,
            emitExtensionBlockSymbols:Bool = true,
            includeInterfaceSymbols:Bool = true,
            skipInheritedDocs:Bool = true)
        {
            self.minimumACL = minimumACL
            self.emitExtensionBlockSymbols = emitExtensionBlockSymbols
            self.includeInterfaceSymbols = includeInterfaceSymbols
            self.skipInheritedDocs = skipInheritedDocs
        }
    }
}
