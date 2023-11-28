import BSONDecoding
import BSONEncoding
import MD5
import SymbolGraphs
import Symbols
import URI

extension Volume
{
    @available(*, deprecated, renamed: "Realm.Sitemap")
    public
    typealias SiteMap = Realm.Sitemap

}
extension Realm
{
    /// A sitemap is a list of all the pages in a volume.
    ///
    /// This type is namespaced to ``Realm`` and not ``Volume`` because we generally only
    /// persist one sitemap per package.
    ///
    /// >   Note:
    ///     Per [sitemaps.org](https://sitemaps.org), the correct spelling is *Sitemap*,
    ///     not *SiteMap*.
    @frozen public
    struct Sitemap:Identifiable, Equatable, Sendable
    {
        public
        let id:Int32
        public
        let elements:Elements

        /// See ``CodingKey.modified``.
        public
        var modified:BSON.Millisecond?
        public
        let hash:MD5

        @inlinable internal
        init(id:Int32,
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
extension Realm.Sitemap
{
    @inlinable public
    init(id:Int32, elements:Elements)
    {
        self.init(id: id,
            elements: elements,
            modified: nil,
            hash: .init(hashing: elements.bytes))
    }
}
extension Realm.Sitemap
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
extension Realm.Sitemap:BSONDocumentEncodable
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
extension Realm.Sitemap:BSONDocumentDecodable
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
