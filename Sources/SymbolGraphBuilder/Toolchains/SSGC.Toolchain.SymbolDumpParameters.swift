import Symbols
import SystemIO

extension SSGC.Toolchain
{
    struct SymbolDumpParameters
    {
        let moduleName:Symbol.Module
        /// I don’t know why `clang` spells `modulemap` as two words.
        var moduleMaps:[FilePath]
        var includePaths:[FilePath.Directory]
        var allowedReexportedModules:[Symbol.Module]

        init(moduleName:Symbol.Module,
            moduleMaps:[FilePath] = [],
            includePaths:[FilePath.Directory] = [],
            allowedReexportedModules:[Symbol.Module] = [])
        {
            self.moduleName = moduleName
            self.moduleMaps = moduleMaps
            self.includePaths = includePaths
            self.allowedReexportedModules = allowedReexportedModules
        }
    }
}
