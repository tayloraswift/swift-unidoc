import BSON
import MongoQL

extension Unidoc.BuildOutcome
{
    @frozen public
    struct Failure:Equatable, Sendable
    {
        public
        let reason:FailureReason

        @inlinable public
        init(reason:FailureReason)
        {
            self.reason = reason
        }
    }
}
extension Unidoc.BuildOutcome.Failure:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case reason = "T"
    }
}
extension Unidoc.BuildOutcome.Failure:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.reason] = self.reason
    }
}
extension Unidoc.BuildOutcome.Failure:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(reason: try bson[.reason].decode())
    }
}
