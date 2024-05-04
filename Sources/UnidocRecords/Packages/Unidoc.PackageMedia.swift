import BSON

extension Unidoc
{
    /// Custom origins for package media. None of the URLs should contain the `https://` prefix.
    @frozen public
    struct PackageMedia:Equatable, Sendable
    {
        public
        var prefix:String

        public
        var gif:String?
        public
        var jpg:String?
        public
        var png:String?
        public
        var svg:String?
        public
        var webp:String?

        @inlinable public
        init(prefix:String,
            gif:String? = nil,
            jpg:String? = nil,
            png:String? = nil,
            svg:String? = nil,
            webp:String? = nil)
        {
            self.prefix = prefix
            self.gif = gif
            self.jpg = jpg
            self.png = png
            self.svg = svg
            self.webp = webp
        }
    }
}
extension Unidoc.PackageMedia
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case prefix = "D"

        case gif
        case jpg
        case png
        case svg
        case webp
    }
}
extension Unidoc.PackageMedia:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.prefix] = self.prefix

        bson[.gif] = self.gif
        bson[.jpg] = self.jpg
        bson[.png] = self.png
        bson[.svg] = self.svg
        bson[.webp] = self.webp
    }
}
extension Unidoc.PackageMedia:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(prefix: try bson[.prefix].decode(),
            gif: try bson[.gif]?.decode(),
            jpg: try bson[.jpg]?.decode(),
            png: try bson[.png]?.decode(),
            svg: try bson[.svg]?.decode(),
            webp: try bson[.webp]?.decode())
    }
}
