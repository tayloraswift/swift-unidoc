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
        let stem:ModuleIdentifier

        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable internal
        init(id:Unidoc.Scalar,
            module:ModuleDetails,
            stem:ModuleIdentifier,
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil)
        {
            self.id = id
            self.module = module
            self.stem = stem
            self.overview = overview
            self.details = details
        }
    }
}
