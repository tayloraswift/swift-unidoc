import Unidoc

extension Record.Master
{
    @frozen public
    struct Article:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        let stem:Record.Stem

        public
        let culture:Unidoc.Scalar

        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable public
        init(id:Unidoc.Scalar,
            stem:Record.Stem,
            culture:Unidoc.Scalar,
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil)
        {
            self.id = id
            self.stem = stem
            self.culture = culture
            self.overview = overview
            self.details = details
        }
    }
}
