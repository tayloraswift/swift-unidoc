import ModuleGraphs
import SemanticVersions
import SHA1
import Unidoc

extension Volume.Vertex
{
    @frozen public
    struct Global:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        @inlinable public
        init(id:Unidoc.Scalar)
        {
            self.id = id
        }
    }
}
