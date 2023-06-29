import Unidoc

extension Record.Master
{
    @frozen public
    struct Article:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable public
        init(id:Unidoc.Scalar, overview:Record.Passage? = nil, details:Record.Passage? = nil)
        {
            self.id = id
            self.overview = overview
            self.details = details
        }
    }
}
