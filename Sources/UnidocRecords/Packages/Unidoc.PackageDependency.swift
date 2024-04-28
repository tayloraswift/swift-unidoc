import BSON

extension Unidoc
{
    @frozen public
    struct PackageDependency:Identifiable, Sendable
    {
        /// A nested document identifying the ``source`` and ``target`` packages.
        public
        let id:Edge<Package>
        /// The latest release version of the ``source`` package.
        public
        var dependent:Version

        @inlinable
        init(id:Edge<Package>, dependent:Version)
        {
            self.id = id
            self.dependent = dependent
        }
    }
}
extension Unidoc.PackageDependency
{
    @inlinable public
    init(dependent:Unidoc.Version, source:Unidoc.Package, target:Unidoc.Package)
    {
        self.init(id: .init(source: source, target: target), dependent: dependent)
    }
}
extension Unidoc.PackageDependency
{
    @inlinable public
    var source:Unidoc.Package { self.id.source }
    @inlinable public
    var target:Unidoc.Package { self.id.target }
}
extension Unidoc.PackageDependency
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case dependent = "V"
    }
}
extension Unidoc.PackageDependency:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.dependent] = self.dependent
    }
}
extension Unidoc.PackageDependency:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(), dependent: try bson[.dependent].decode())
    }
}
