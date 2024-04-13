import SymbolGraphs
import System

extension SSGC
{
    protocol DocumentationBuild
    {
        mutating
        func compile(into artifaces:FilePath,
            with swift:Toolchain) throws -> (SymbolGraphMetadata, SSGC.PackageSources)
    }
}
