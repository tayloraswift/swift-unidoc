import ModuleGraphs
import Symbols
import Unidoc

/// A combined mapping of symbols to global scalars across all upstream dependencies.
/// Within a build tree, we assume module names are unique, which implies that symbol
/// manglings should never collide.
extension DynamicContext
{
    struct UpstreamScalars
    {
        var cultures:[ModuleIdentifier: Unidoc.Scalar]
        var citizens:[Symbol.Decl: Unidoc.Scalar]

        init()
        {
            self.cultures = [:]
            self.citizens = [:]
        }
    }
}
