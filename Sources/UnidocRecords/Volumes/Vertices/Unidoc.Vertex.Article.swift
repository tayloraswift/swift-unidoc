import FNV1
import MarkdownABI
import Unidoc
import UnidocAPI

extension Unidoc.Vertex
{
    @frozen public
    struct Article:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        var stem:Unidoc.Stem

        public
        var culture:Unidoc.Scalar
        public
        var file:Unidoc.Scalar?

        public
        var headline:MarkdownBytecode
        public
        var overview:Unidoc.Passage?
        public
        var details:Unidoc.Passage?
        public
        var group:Unidoc.Group.ID?

        @inlinable public
        init(id:Unidoc.Scalar,
            stem:Unidoc.Stem,
            culture:Unidoc.Scalar,
            file:Unidoc.Scalar? = nil,
            headline:MarkdownBytecode = [],
            overview:Unidoc.Passage? = nil,
            details:Unidoc.Passage? = nil,
            group:Unidoc.Group.ID? = nil)
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
extension Unidoc.Vertex.Article
{
    @inlinable public
    var shoot:Unidoc.Shoot
    {
        .init(stem: self.stem)
    }
}
