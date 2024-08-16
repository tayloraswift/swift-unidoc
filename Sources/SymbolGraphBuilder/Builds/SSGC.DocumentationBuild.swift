import SymbolGraphs
import System

extension SSGC
{
    protocol DocumentationBuild
    {
        mutating
        func compile(updating status:SSGC.StatusStream?,
            cache:FilePath.Directory,
            with swift:Toolchain,
            clean:Bool) throws -> (SymbolGraphMetadata, any DocumentationSources)
    }
}
