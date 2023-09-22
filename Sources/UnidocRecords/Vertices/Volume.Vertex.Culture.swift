import ModuleGraphs
import Unidoc

extension Volume.Vertex
{
    @frozen public
    struct Culture:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let module:ModuleDetails
        public
        var readme:Unidoc.Scalar?
        public
        var census:Volume.Census

        public
        var overview:Volume.Passage?
        public
        var details:Volume.Passage?
        public
        var group:Unidoc.Scalar?

        @inlinable public
        init(id:Unidoc.Scalar,
            module:ModuleDetails,
            readme:Unidoc.Scalar? = nil,
            census:Volume.Census = .init(),
            overview:Volume.Passage? = nil,
            details:Volume.Passage? = nil,
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
extension Volume.Vertex.Culture
{
    @inlinable public
    var shoot:Volume.Shoot
    {
        .init(stem: self.stem)
    }

    @inlinable public
    var stem:Volume.Stem
    {
        .init(self.module.id)
    }
}
