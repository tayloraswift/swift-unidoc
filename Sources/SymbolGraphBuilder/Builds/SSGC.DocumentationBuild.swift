import SymbolGraphs
import System

extension SSGC
{
    protocol DocumentationBuild<Sources>
    {
        associatedtype Sources:DocumentationSources

        mutating
        func compile(updating status:SSGC.StatusStream?,
            into artifacts:FilePath.Directory,
            with swift:Toolchain) throws -> (SymbolGraphMetadata, Sources)
    }
}
