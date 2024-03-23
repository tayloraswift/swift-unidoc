import BSON
import Durations
import MongoQL

extension Unidoc.BuildOutcome
{
    @frozen public
    struct Failure:Equatable, Sendable
    {
        public
        var timeoutAfter:Milliseconds?

        init(timeoutAfter:Milliseconds?)
        {
            self.timeoutAfter = timeoutAfter
        }
    }
}
extension Unidoc.BuildOutcome.Failure:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case timeoutAfter = "T"
    }
}
extension Unidoc.BuildOutcome.Failure:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.timeoutAfter] = self.timeoutAfter
    }
}
extension Unidoc.BuildOutcome.Failure:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(timeoutAfter: try bson[.timeoutAfter]?.decode())
    }
}
