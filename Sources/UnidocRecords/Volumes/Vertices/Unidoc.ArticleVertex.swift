import FNV1
import MarkdownABI
import Unidoc
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct ArticleVertex:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        var stem:Unidoc.Stem

        public
        var culture:Unidoc.Scalar
        public
        var readme:Unidoc.Scalar?

        @available(*, deprecated, renamed: "readme")
        public
        var file:Unidoc.Scalar? { self.readme }

        public
        var headline:Markdown.Bytecode
        public
        var overview:Unidoc.Passage?
        public
        var details:Unidoc.Passage?
        public
        var group:Unidoc.Group?

        @inlinable public
        init(id:Unidoc.Scalar,
            stem:Unidoc.Stem,
            culture:Unidoc.Scalar,
            readme:Unidoc.Scalar? = nil,
            headline:Markdown.Bytecode = [],
            overview:Unidoc.Passage? = nil,
            details:Unidoc.Passage? = nil,
            group:Unidoc.Group? = nil)
        {
            self.id = id
            self.stem = stem

            self.culture = culture
            self.readme = readme

            self.headline = headline
            self.overview = overview
            self.details = details
            self.group = group
        }
    }
}
extension Unidoc.ArticleVertex:Unidoc.PrincipalVertex
{
    @inlinable public
    var hash:FNV24.Extended { .init(hashing: "\(self.stem)") }
}
