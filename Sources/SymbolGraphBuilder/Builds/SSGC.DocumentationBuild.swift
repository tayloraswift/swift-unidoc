import SymbolGraphs
import System

extension SSGC
{
    protocol DocumentationBuild
    {
        mutating
        func compile(updating status:SSGC.StatusStream?,
            into artifacts:FilePath.Directory,
            with swift:Toolchain) throws -> (SymbolGraphMetadata, any DocumentationSources)
    }
}
