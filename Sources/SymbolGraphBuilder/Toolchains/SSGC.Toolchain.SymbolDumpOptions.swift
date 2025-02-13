import Symbols
import SystemIO

extension SSGC.Toolchain
{
    struct SymbolDumpOptions
    {
        /// Despite the name, this is the *mangled* C99 name, not the file system name.
        let moduleName:Symbol.Module
        /// I don’t know why `clang` spells `modulemap` as two words.
        var moduleMaps:[FilePath]
        var includePaths:[FilePath.Directory]
        var allowedReexportedModules:[Symbol.Module]

        var minimumAccessLevel:Symbol.ACL
        var emitExtensionBlockSymbols:Bool
        var includeInterfaceSymbols:Bool
        var skipInheritedDocs:Bool

        init(moduleName:Symbol.Module,
            moduleMaps:[FilePath] = [],
            includePaths:[FilePath.Directory] = [],
            allowedReexportedModules:[Symbol.Module] = [],
            minimumAccessLevel:Symbol.ACL = .internal,
            emitExtensionBlockSymbols:Bool = true,
            includeInterfaceSymbols:Bool = true,
            skipInheritedDocs:Bool = true)
        {
            self.moduleName = moduleName
            self.moduleMaps = moduleMaps
            self.includePaths = includePaths
            self.allowedReexportedModules = allowedReexportedModules
            self.minimumAccessLevel = minimumAccessLevel
            self.emitExtensionBlockSymbols = emitExtensionBlockSymbols
            self.includeInterfaceSymbols = includeInterfaceSymbols
            self.skipInheritedDocs = skipInheritedDocs
        }
    }
}
