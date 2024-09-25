import SemanticVersions
import SymbolGraphs

extension Unidoc
{
    @frozen public
    struct BuildTemplate:Equatable, Sendable
    {
        public
        var toolchain:PatchVersion?
        public
        var platform:Triple?

        @inlinable public
        init()
        {
        }

        @inlinable public
        init(toolchain:PatchVersion?, platform:Triple?)
        {
            self.toolchain = toolchain
            self.platform = platform
        }
    }
}
