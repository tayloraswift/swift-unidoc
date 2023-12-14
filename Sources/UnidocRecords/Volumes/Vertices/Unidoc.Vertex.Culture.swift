import SymbolGraphs
import Unidoc

extension Unidoc.Vertex
{
    @frozen public
    struct Culture:Identifiable, Equatable, Sendable
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
        var group:Unidoc.Scalar?

        @inlinable public
        init(id:Unidoc.Scalar,
            module:SymbolGraph.Module,
            readme:Unidoc.Scalar? = nil,
            census:Unidoc.Census = .init(),
            overview:Unidoc.Passage? = nil,
            details:Unidoc.Passage? = nil,
            group:Unidoc.Scalar? = nil)
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
extension Unidoc.Vertex.Culture
{
    @inlinable public
    var shoot:Unidoc.Shoot
    {
        .init(stem: self.stem)
    }

    @inlinable public
    var stem:Unidoc.Stem
    {
        .init(self.module.id)
    }
}
