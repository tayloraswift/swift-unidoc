import Symbols

extension SSGC.Toolchain
{
    struct SymbolDumpOptions
    {
        var minimumACL:Symbol.ACL
        var allowedReexportedModules:[Symbol.Module]
        var emitExtensionBlockSymbols:Bool
        var includeInterfaceSymbols:Bool
        var skipInheritedDocs:Bool

        init(minimumACL:Symbol.ACL = .internal,
            allowedReexportedModules:[Symbol.Module] = [],
            emitExtensionBlockSymbols:Bool = true,
            includeInterfaceSymbols:Bool = true,
            skipInheritedDocs:Bool = true)
        {
            self.minimumACL = minimumACL
            self.allowedReexportedModules = allowedReexportedModules
            self.emitExtensionBlockSymbols = emitExtensionBlockSymbols
            self.includeInterfaceSymbols = includeInterfaceSymbols
            self.skipInheritedDocs = skipInheritedDocs
        }
    }
}
