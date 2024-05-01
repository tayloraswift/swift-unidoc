import BSON

extension Unidoc
{
    /// We call this `EditionDependency` and not `VolumeDependency` because the target edition
    /// may not have an associated volume.
    @frozen public
    struct EditionDependency:Identifiable, Sendable
    {
        public
        let id:Edge<Edition>

        @inlinable
        init(id:Edge<Edition>)
        {
            self.id = id
        }
    }
}
extension Unidoc.EditionDependency
{
    @inlinable public
    init(source:Unidoc.Edition, target:Unidoc.Edition)
    {
        self.init(id: .init(source: source, target: target))
    }
}
extension Unidoc.EditionDependency
{
    @inlinable public
    var source:Unidoc.Edition { self.id.source }
    @inlinable public
    var target:Unidoc.Edition { self.id.target }
}
extension Unidoc.EditionDependency
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
    }
}
extension Unidoc.EditionDependency:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
    }
}
extension Unidoc.EditionDependency:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode())
    }
}
