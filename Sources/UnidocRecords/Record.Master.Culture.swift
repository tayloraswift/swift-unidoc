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
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable public
        init(id:Unidoc.Scalar,
            module:ModuleDetails,
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil)
        {
            self.id = id
            self.module = module
            self.overview = overview
            self.details = details
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
