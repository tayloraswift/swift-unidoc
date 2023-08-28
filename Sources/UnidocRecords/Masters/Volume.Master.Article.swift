import MarkdownABI
import Unidoc

extension Volume.Master
{
    @frozen public
    struct Article:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        var stem:Volume.Stem

        public
        var culture:Unidoc.Scalar
        public
        var file:Unidoc.Scalar?

        public
        var headline:MarkdownBytecode
        public
        var overview:Volume.Passage?
        public
        var details:Volume.Passage?
        public
        var group:Unidoc.Scalar?

        @inlinable public
        init(id:Unidoc.Scalar,
            stem:Volume.Stem,
            culture:Unidoc.Scalar,
            file:Unidoc.Scalar? = nil,
            headline:MarkdownBytecode = [],
            overview:Volume.Passage? = nil,
            details:Volume.Passage? = nil,
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
extension Volume.Master.Article
{
    @inlinable public
    var shoot:Volume.Shoot
    {
        .init(stem: self.stem)
    }
}
