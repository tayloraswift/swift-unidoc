import ModuleGraphs
import Unidoc

extension Record.Master
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
        var overview:Record.Passage?
        public
        var details:Record.Passage?
        public
        var group:Unidoc.Scalar?

        @inlinable public
        init(id:Unidoc.Scalar,
            module:ModuleDetails,
            readme:Unidoc.Scalar? = nil,
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil,
            group:Unidoc.Scalar? = nil)
        {
            self.id = id

            self.module = module
            self.readme = readme

            self.overview = overview
            self.details = details
            self.group = group
        }
    }
}
extension Record.Master.Culture
{
    @inlinable public
    var stem:Record.Stem
    {
        .init(self.module.id)
    }
}
