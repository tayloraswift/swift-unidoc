import BSON

extension Unidoc
{
    @frozen public
    struct BuildFailure:Equatable, Sendable
    {
        public
        let reason:Reason

        @inlinable public
        init(reason:Reason)
        {
            self.reason = reason
        }
    }
}
extension Unidoc.BuildFailure
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case reason = "T"
    }
}
extension Unidoc.BuildFailure:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.reason] = self.reason
    }
}
extension Unidoc.BuildFailure:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(reason: try bson[.reason].decode())
    }
}
