import SymbolGraphs
import System

extension SSGC
{
    protocol DocumentationBuild
    {
        mutating
        func compile(updating status:SSGC.StatusStream?,
            into artifacts:FilePath,
            with swift:Toolchain) throws -> (SymbolGraphMetadata, SSGC.PackageSources)
    }
}
