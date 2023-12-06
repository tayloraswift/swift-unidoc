import BSON
import MD5
import SymbolGraphs
import Symbols
import Unidoc
import URI

extension Volume
{
    @available(*, deprecated, renamed: "Unidex.Sitemap")
    public
    typealias SiteMap = Unidex.Sitemap

}
extension Unidex
{
    /// A sitemap is a list of all the pages in a volume.
    ///
    /// This type is namespaced to ``Unidex`` and not ``Volume`` because we generally only
    /// persist one sitemap per package.
    ///
    /// >   Note:
    ///     Per [sitemaps.org](https://sitemaps.org), the correct spelling is *Sitemap*,
    ///     not *SiteMap*.
    @frozen public
    struct Sitemap:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Package
        public
        let elements:Elements

        /// See ``CodingKey.modified``.
        public
        var modified:BSON.Millisecond?
        public
        let hash:MD5

        @inlinable internal
        init(id:Unidoc.Package,
            elements:Elements,
            modified:BSON.Millisecond?,
            hash:MD5)
        {
            self.id = id
            self.elements = elements
            self.modified = modified
            self.hash = hash
        }
    }
}
extension Unidex.Sitemap
{
    @inlinable public
    init(id:Unidoc.Package, elements:Elements)
    {
        self.init(id: id,
            elements: elements,
            modified: nil,
            hash: .init(hashing: elements.bytes))
    }
}
extension Unidex.Sitemap
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case elements = "L"
        /// When this sitemap was last modified. This field only appears if the sitemap has
        /// changed at least once since it was created.
        case modified = "M"
        case hash = "H"
    }
}
extension Unidex.Sitemap:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.elements] = self.elements
        bson[.modified] = self.modified
        bson[.hash] = self.hash
    }
}
extension Unidex.Sitemap:BSONDocumentDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        self.init(id: try bson[.id].decode(),
            elements: try bson[.elements].decode(),
            modified: try bson[.modified]?.decode(),
            hash: try bson[.hash].decode())
    }
}