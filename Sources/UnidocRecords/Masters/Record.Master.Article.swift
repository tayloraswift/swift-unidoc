import MarkdownABI
import Unidoc

extension Record.Master
{
    @frozen public
    struct Article:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        var stem:Record.Stem

        public
        var culture:Unidoc.Scalar
        public
        var file:Unidoc.Scalar?

        public
        var headline:MarkdownBytecode
        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?
        public
        var group:Unidoc.Scalar?

        @inlinable public
        init(id:Unidoc.Scalar,
            stem:Record.Stem,
            culture:Unidoc.Scalar,
            file:Unidoc.Scalar? = nil,
            headline:MarkdownBytecode = [],
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil,
            group:Unidoc.Scalar? = nil)
        {
            self.id = id
            self.stem = stem

            self.culture = culture
            self.file = file

            self.headline = headline
            self.overview = overview
            self.details = details
            self.group = group
        }
    }
}
