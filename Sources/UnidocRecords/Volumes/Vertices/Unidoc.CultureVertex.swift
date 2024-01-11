import FNV1
import SymbolGraphs
import Unidoc
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct CultureVertex:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let module:SymbolGraph.Module
        public
        var readme:Unidoc.Scalar?
        public
        var census:Unidoc.Census

        public
        var overview:Unidoc.Passage?
        public
        var details:Unidoc.Passage?
        public
        var group:Unidoc.Group?

        @inlinable public
        init(id:Unidoc.Scalar,
            module:SymbolGraph.Module,
            readme:Unidoc.Scalar? = nil,
            census:Unidoc.Census = .init(),
            overview:Unidoc.Passage? = nil,
            details:Unidoc.Passage? = nil,
            group:Unidoc.Group? = nil)
        {
            self.id = id

            self.module = module
            self.readme = readme
            self.census = census

            self.overview = overview
            self.details = details
            self.group = group
        }
    }
}
extension Unidoc.CultureVertex:Unidoc.PrincipalVertex
{
    @inlinable public
    var stem:Unidoc.Stem { .module(self.module.id) }

    @inlinable public
    var hash:FNV24.Extended { .init(hashing: "s:m:\(self.module.id)") }
}
