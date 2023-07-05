import ModuleGraphs
import Symbols
import Unidoc

/// A combined mapping of symbols to global scalars across all upstream dependencies.
/// Within a build tree, we assume module names are unique, which implies that symbol
/// manglings should never collide.
extension DynamicContext
{
    @frozen public
    struct UpstreamScalars
    {
        public
        var cultures:[ModuleIdentifier: Unidoc.Scalar]
        public
        var citizens:[Symbol.Decl: Unidoc.Scalar]

        @inlinable public
        init()
        {
            self.cultures = [:]
            self.citizens = [:]
        }
    }
}
